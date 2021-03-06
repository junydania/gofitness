class Admin::MembersController < ApplicationController

    load_and_authorize_resource param_method: :member_params
    
    skip_authorize_resource :only => :send_paystack_invoice

    before_action :authenticate_user!
    
    before_action :find_member, only: [:renew_membership,
                                       :pos_renewal,
                                       :cash_renewal,
                                       :check_paystack_subscription,
                                       :unsubscribe_membership, 
                                       :pause_subscription, 
                                       :cancel_pause,
                                       :wallet_renewal,
                                       :update,
                                       :complete_activation,
                                       :change_plan,
                                       :send_paystack_invoice ]
                                       
    before_action :get_paystack_object, only: [:check_paystack_subscription,
                                               :paystack_renewal,
                                               :initiate_paystack_sub,
                                               :unsubscribe_membership,
                                               :pause_subscription,
                                               :cancel_pause,
                                               :change_plan_update,
                                               :send_paystack_invoice ]

    require 'securerandom'
    require 'payment_processing'
    require 'accounting'


    def index
      @filterrific = initialize_filterrific(
        Member.with_account_details,
          params[:filterrific],
          select_options: {
            with_subscription_plan_id: SubscriptionPlan.options_for_select,
            with_fitness_goal_id: FitnessGoal.options_for_select,
            with_payment_method_id: PaymentMethod.options_for_select,
            sorted_by: Member.options_for_sorted_by
          },
          persistence_id: 'shared_key',
          default_filter_params: {},
      ) or return
      @members = @filterrific.find.page(params[:page]).per_page(15)
      
      respond_to do |format|
        format.html
        format.js
      end

      rescue ActiveRecord::RecordNotFound => e
        puts "Had to reset filterrific params: #{ e.message }"
        redirect_to(reset_filterrific_url(format: :html)) && return
    end

    def new
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      @member = Member.new
    end

    def edit
      @subscription_plans = SubscriptionPlan.all
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      @member = Member.find(params[:id])
    end

    def update
      existing_code = Member.find_by(customer_code: member_params[:customer_Code])
      if existing_code.customer_code.nil?
        if @member.update(member_params)
          @member.save
          redirect_to image_page_path(@member)
          flash[:notice] = "#{@member.first_name}'s profile updated"
        else
          render :edit
        end
      else
        flash[:notice] = "Customer Code already exists in the system"
        render :edit
      end
    end

    def image_capture
      session[:member_id] = params[:id]
      render
    end

    def upload_image
      member_image = Shrine.data_uri(params[:image])
      member = Member.find(session[:member_id])
      member.image = member_image
      if member.save
          render json: {
              message: "Image Uploaded"
          } 
      else
          render status: 500, json: {
              message: "Failed to Upload"
          }
      end
    end


    def show
      @member = Member.find(params[:id])
      @member_activities = @member.own_and_associated_audits.limit(10)
    end


    def create
        member_exists = Member.find_by(email: member_params[:email])
        if !member_params.key?("start_date")
          start_date = DateTime.now
        else
          start_date = !member_params["start_date"].empty? ? Date.strptime(member_params["start_date"], '%m/%d/%Y').to_datetime : DateTime.now
        end
        if !member_exists.nil? && member_exists.subscription_histories.count > 0
          flash[:error] = "Email Exists with subscription records! Provide unique emai address"
          render :new
        elsif !member_exists.nil? && member_exists.subscription_histories.count <= 0
          redirect_to admin_member_steps_path
        elsif member_exists.nil? && !member_params[:subscription_plan_id].empty?
          add_new_member(member_params, start_date)
        else
          flash[:error] = "Couldn't create member account! Ensure all fields are filled!"
          render :new
        end
    end

    # Hack to set adjust subscribe start date it falls above 28th of the month
    # Paystack does not permit subscription payment after 28th of every month.
    # customers who walk into the gym after 28th will have their subscription started
    # on the second day of the following month
    def included_in_restricted_date?(start_date)
      ["29", "30", "31"].include? start_date.strftime("%d")
    end

    def activate_account
        @member = Member.find(params[:id])
    end

    def complete_activation
      if @member.update(member_params)
        flash[:notice] = "Proceed with payment!"
        redirect_to admin_member_steps_path
      end
    end

    def send_paystack_invoice
      due_date = 7.days.from_now.strftime('%F')
      payload = {
        :description => @member.subscription_plan.description,
        :line_items => [
          {:name => @member.subscription_plan.plan_name, :amount => @member.subscription_plan.cost * 100}
        ],
        :customer => @member.paystack_cust_code,
        :due_date => 7.days.from_now.strftime('%F'),
        :send_notification => true
      }
      send_invoice = nil  
      begin
        uri = URI('https://api.paystack.co/paymentrequest')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json',
          'Authorization' => "Bearer #{ENV["PAYSTACK_PRIVATE_KEY"]}"})
        req.body = payload.to_json
        res = http.request(req)
        send_invoice = JSON.parse(res.body)
      rescue => e
          puts "failed #{e}"
      end
      if send_invoice["status"] == true
        render status: 200, json: {
          message: "success"
        }
      else
        render status: 500, json: {
          message: "failed"
        }
      end
    end


    def change_plan
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
    end

    def change_plan_update
      if DateTime.now > @member.account_detail.expiry_date && @member.paystack_subscription_code.nil?
        plan = SubscriptionPlan.where(id: member_params['subscription_plan_id']).first
        if plan.recurring == true
          payment_method_id = PaymentMethod.where(payment_system: "Debit Card").first.id
        else
          payment_method_id = PaymentMethod.where(payment_system: ["Cash","Pos Terminal"]).first.id
        end
        updated_params = member_params.clone
        updated_params["payment_method_id"] = payment_method_id
        if @member.update(updated_params)
          session[:member_id] = params["id"]
          redirect_to admin_member_steps_path
        else
          render :change_plan
          flash[:notice] = "Check entry, couldn't save!"
        end
      elsif DateTime.now > @member.account_detail.expiry_date && !@member.paystack_subscription_code.nil?
        unsubscribe = disable_current_paystack_subscription
        if unsubscribe["status"] == true
          subscription_status = 1
          subscribe_date = @member.account_detail.subscribe_date
          expiry_date = @member.account_detail.expiry_date
          @member.account_detail.member_status = 1
          @member.account_detail.unsubscribe_date = DateTime.now
          @member.account_detail.audit_comment = "membership de-activated"
          @member.paystack_subscription_code = nil
          @member.paystack_email_token = nil
          @member.paystack_auth_code = nil
          @member.save    
          create_subscription_history(subscribe_date, expiry_date, subscription_status)
          @member.update(member_params)    
          redirect_to admin_member_steps_path
        end
      else
        flash[:notice] = "Customer still has an active plan! Wait till it expires"
        redirect_to member_profile_path(@member)
      end
    end

    def renew_membership
      gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
      gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
      gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
      gon.member_id = @member.id
      session[:member_id] = @member.id
    end

    def wallet_renewal
      member = Member.find(params[:id].to_i)
      wallet_balance = member.wallet_detail.current_balance.to_i
      current_plan_cost = member.subscription_plan.cost.to_i
      if wallet_balance >= current_plan_cost
        new_balance = wallet_balance - current_plan_cost
        subscribe_date, recurring, amount = set_subscribe_date, false, current_plan_cost
        expiry_date, payment_method = set_expiry_date(subscribe_date), "Wallet"
        subscription_status, fund_method = 0, "Wallet"
        update_wallet_detail(member, amount, wallet_balance, new_balance)
        update_wallet_histories(member, amount, wallet_balance, new_balance, fund_method)
        update_all_records(subscribe_date, expiry_date, recurring, amount, payment_method, subscription_status)
        render status: 200, json: {
          message: "success"
        }
      else
        render status: 200, json: {
          message: "insufficient funds"
      }
      end
    end
    
    def cash_renewal
      cash_received = member_params["cash_transactions_attributes"]["0"]["amount_received"].to_i
      customer_current_amount = @member.account_detail.amount
      if cash_received ==  customer_current_amount
        subscribe_date, recurring, amount = set_subscribe_date, false, retrieve_amount
        expiry_date, payment_method = set_expiry_date(subscribe_date), retrieve_payment_method
        subscription_status = 0
        create_cash_transaction(cash_received)
        update_all_records(subscribe_date, expiry_date, recurring, amount, payment_method, subscription_status)
        create_attendance_record
        options = {description: 'Member Renewal', amount: amount}
        Accounting::Entry.new(options).cash_entry
        redirect_to member_profile_path(@member)
      else
        flash[:notice] = "Sorry Wrong Amount Received! Enter correct amount or change customer plan"
        redirect_to renew_member_path(@member)
      end
    end

    def pos_renewal
      transaction_reference = member_params["pos_transactions_attributes"]["0"]["transaction_reference"]
      transaction_success_param = member_params["pos_transactions_attributes"]["0"]["transaction_success"]
      transaction_success = true?(transaction_success_param)
      if !transaction_reference.nil? && transaction_success == true
        subscribe_date, recurring, amount = set_subscribe_date, false, retrieve_amount
        expiry_date, payment_method = set_expiry_date(subscribe_date), retrieve_payment_method
        subscription_status = 0
        create_pos_transaction(transaction_reference, transaction_success_param)
        update_all_records(subscribe_date, expiry_date, recurring, amount, payment_method, subscription_status)
        create_attendance_record
        options = {description: 'Member Renewal', amount: amount}
        Accounting::Entry.new(options).card_entry
        redirect_to member_profile_path(@member)
      else
        flash[:notice] = "Sorry! Enter the POS Transaction Reference ID & Confirm if transaction was successful"
        redirect_to renew_member_path(@member)
      end  
    end

    def paystack_renewal
      if check_paystack_subscription == true
        disable_current_paystack_subscription
        paystack_subscribe
      else
        paystack_subscribe
      end
    end

    def unsubscribe_membership
      unsubscribe = disable_current_paystack_subscription
      if unsubscribe["status"] == true
        subscription_status = 1
        if @member.account_detail.expiry_date < DateTime.now 
           @member.account_detail.member_status = 1
           @member.account_detail.unsubscribe_date = DateTime.now
           @member.account_detail.audit_comment = "membership de-activated"
           @member.save    
           create_subscription_history(subscribe_date, expiry_date, subscription_status)
           redirect_to member_profile_path(@member)
        else 
          subscribe_date = @member.account_detail.subscribe_date
          expiry_date = @member.account_detail.expiry_date
          @member.account_detail.unsubscribe_date = DateTime.now
          @member.save
          create_subscription_history(subscribe_date, expiry_date, subscription_status)
          redirect_to member_profile_path(@member)
        end
      else
        flash[:notice] = "Customer doesn't have recurring membership plan"
        redirect_to member_profile_path(@member)
      end
    end

    def pause_subscription
     customer_plan_duration = @member.subscription_plan.duration
     case customer_plan_duration 
     when "monthly"
        if @member.account_detail.pause_permit_count < 2
          pause_subscription_steps
        else
          render status: 200, json: {
            message: "pause exceeded"
          }
        end
     when "quarterly"
        if @member.account_detail.pause_permit_count < 3
          pause_subscription_steps
        else
          render status: 200, json: {
            message: "pause exceeded"
          }
        end
     when "annually"
        if @member.account_detail.pause_permit_count < 5
          pause_subscription_steps
        else
          render status: 200, json: {
            message: "pause exceeded"
          }
        end
      end
    end

    def cancel_pause 
      auth_code, current_date = @member.paystack_auth_code.to_s, DateTime.now
      previous_expiry_date = @member.account_detail.expiry_date.to_datetime
      previous_pause_start_date = @member.account_detail.pause_start_date.to_datetime
      duration = (current_date - previous_pause_start_date).to_f.ceil
      new_expiry_date = previous_expiry_date + duration
      paystack_charge_date = new_expiry_date.to_s
      paystack_customer_code = @member.paystack_cust_code.to_s
      plan_code = @member.subscription_plan.paystack_plan_code.to_s
      subscription_code = @member.paystack_subscription_code.to_s
      email_token = @member.paystack_email_token.to_s
      create_subscription = initiate_paystack_sub
      subscribe = create_subscription.create( customer: paystack_customer_code,
                                              plan: plan_code,
                                              authorization: auth_code,
                                              start_date: paystack_charge_date,
                                            )
      if subscribe["status"] == true
          enable_subscription = create_subscription.enable(code: subscription_code, token: email_token)
          @member.pause_histories.create(
              pause_start_date: @member.account_detail.pause_start_date,
              pause_cancel_date: @member.account_detail.pause_cancel_date,
              paused_by: current_user.fullname,
              pause_actual_cancel_date: current_date )

          @member.account_detail.update(
                  expiry_date: new_expiry_date,
                  member_status: 0,
                  pause_start_date: nil,
                  pause_cancel_date: nil,
                  audit_comment: 'membership pause cancelled' )
          create_attendance_record
          render status: 200, json: {
            message: "success"
          }  
      else
        render status: 200, json: {
          message: "failed"
        }
      end   
    end


    private

    def true?(obj)
      obj.to_s == "true"
    end


    def add_new_member(member_params, start_date)
      new_member = Member.new(member_params)
      plan = SubscriptionPlan.find(new_member.subscription_plan_id)
      if plan.recurring == true
        payment = PaymentMethod.find_by(payment_system: 'Debit Card').id
        new_member.payment_method_id = payment
        start_date = included_in_restricted_date?(start_date) ? start_date.at_beginning_of_month.next_month + 1.day : start_date
      end
      if new_member.save
        new_member.audits.last.user
        session[:member_id] = new_member.id
        member = Member.find(new_member.id)
        account_update = member.build_account_detail(
          subscribe_date: start_date,
          expiry_date: start_date,
          member_status: 1,
          gym_attendance_status: 0,
          audit_comment: "New account created for member")
        account_update.save
        flash[:notice] = "Collect Payment & Complete the Registration Process"
        redirect_to admin_member_steps_path
      end

    end

    def update_wallet_detail(member, amount, wallet_balance, new_balance)
      date_last_funded = member.wallet_detail.date_last_funded
      total_funded = member.wallet_detail.total_amount_funded
      total_amount_used = member.wallet_detail.total_amount_used + amount
      current_wallet_expiry_date = member.wallet_detail.wallet_expiry_date
      member.wallet_detail.update(
          current_balance: new_balance,
          total_amount_funded: total_funded,
          amount_last_funded: amount, 
          total_amount_used: total_amount_used,
          wallet_expiry_date:  current_wallet_expiry_date,
          wallet_status: 0,
          date_last_funded: date_last_funded,
          audit_comment: 'funded wallet'
      )
    end


    def update_wallet_histories(member, amount, wallet_balance, new_balance, fund_method)
      member.wallet_histories.create(
           amount_paid_in: 0,
           wallet_previous_balance: wallet_balance,
           amount_used: amount,
           processed_by: current_user.fullname,
           wallet_new_balance: new_balance,
           wallet_fund_method: 2,)
    end
    
    
    def pause_subscription_steps
      if check_paystack_subscription == true
        disable_current_paystack_subscription
        update_pause_account_detail
        create_pause_history
        render status: 200, json: {
          message: "success"
        }
      else
        render status: 200, json: {
          message: "no subscription"
        }
      end
    end

    def create_pause_history
      @member.pause_histories.create(
        pause_start_date: @member.account_detail.pause_start_date,
        pause_cancel_date: @member.account_detail.pause_cancel_date,
        paused_by: current_user.fullname,
        audit_comment: "membership paused")
    end

    def update_pause_account_detail
        @member.account_detail.pause_permit_count = @member.account_detail.pause_permit_count + 1
        @member.account_detail.pause_start_date = DateTime.now
        @member.account_detail.pause_cancel_date = DateTime.now + 7
        @member.account_detail.member_status = 2
        @member.account_detail.audit_comment = 'membership paused'
        @member.save
    end

    def update_all_records(subscribe_date, expiry_date, recurring, amount, payment_method, subscription_status)
      create_charge
      update_account_detail(subscribe_date, expiry_date, recurring)
      create_subscription_history(subscribe_date, expiry_date, subscription_status)
      create_loyalty_history(amount)
      create_general_transaction(subscribe_date, amount, payment_method)
    end


    def retrieve_payment_method
      @member.payment_method.payment_system
    end

    def create_pos_transaction(transaction_reference, transaction_success_param)
      pos_transaction = @member.pos_transactions.create(
                                      transaction_success: transaction_success_param,
                                      transaction_reference: transaction_reference,
                                      processed_by: current_user.fullname,
                                      audit_comment: "Membership renewal paid using POS" )
      return pos_transaction
    end


    def create_cash_transaction(cash_received)
        cash_transaction = @member.cash_transactions.create(
                                        amount_received: cash_received,
                                        cash_received_by: current_user.fullname,
                                        service_paid_for: 'Membership renewal paid using cash',
        )
        return cash_transaction
    end

    def update_account_detail(subscribe_date, expiry_date, recurring)
      amount = retrieve_amount
      account_update = @member.account_detail.update(
                                  subscribe_date:subscribe_date,
                                  expiry_date: expiry_date,
                                  member_status: 0,
                                  amount: amount,
                                  unsubscribe_date: nil,
                                  loyalty_points_balance: update_loyalty_points(amount),
                                  loyalty_points_used: 0,
                                  gym_plan: retrieve_gym_plan,
                                  recurring_billing: recurring,
                                  audit_comment: 'Membership renewed',)
    end

    def create_charge
      charge = @member.charges.new(service_plan: retrieve_gym_plan,
                                  amount: retrieve_amount,
                                  payment_method: retrieve_payment_method,
                                  duration: @member.subscription_plan.duration,
                                  gofit_transaction_id: SecureRandom.hex(4) 
                                  )
      if charge.save
          MemberMailer.renewal(@member).deliver_later
      end
    end

    def create_subscription_history(subscribe_date, expiry_date, subscription_status)
      subscription_history = @member.subscription_histories.create(
          subscribe_date: subscribe_date,
          expiry_date: expiry_date,
          subscription_type: 1,
          subscription_plan: retrieve_gym_plan,
          amount: retrieve_amount,
          payment_method: retrieve_payment_method,
          member_status: 0,
          subscription_status: subscription_status,
          )
    end

    def update_loyalty_points(amount)
      point = Loyalty.find_by(loyalty_type: "renewal").loyalty_points_percentage
      point = ((point * 0.01) * amount).to_i
      new_point = @member.account_detail.loyalty_points_balance + point
      return new_point.to_i
   end


   def get_loyalty_points(amount)
    point = Loyalty.find_by(loyalty_type: "renewal").loyalty_points_percentage
    point = ((point * 0.01) * amount).to_i
   end


   def create_loyalty_history(amount)
      loyalty_history = @member.loyalty_histories.create(
          points_earned: get_loyalty_points(amount),
          points_redeemed: 0,
          loyalty_transaction_type: 1,
          loyalty_balance: update_loyalty_points(amount),
          )
   end


    def set_subscribe_date
      date = DateTime.now.strftime('%d-%m-%Y %H:%M:%S')
    end


    def retrieve_amount
      amount = @member.subscription_plan.cost
   end

    def retrieve_gym_plan
        plan = @member.subscription_plan.plan_name
    end

    def set_expiry_date(subscribe_date)
      expiry_date = DateTime.new
      if @member.subscription_plan.duration == "daily"
          expiry_date =  (DateTime.parse(subscribe_date) + 1).strftime('%d-%m-%Y %H:%M:%S')
      elsif @member.subscription_plan.duration == "weekly"
          expiry_date =  (DateTime.parse(subscribe_date) + 7).strftime('%d-%m-%Y %H:%M:%S')
      elsif @member.subscription_plan.duration == "monthly"
          expiry_date =  (DateTime.parse(subscribe_date) + 30).strftime('%d-%m-%Y %H:%M:%S')
      elsif @member.subscription_plan.duration == "quarterly"
          expiry_date =  (DateTime.parse(subscribe_date) + 90).strftime('%d-%m-%Y %H:%M:%S')
      elsif @member.subscription_plan.duration == "annually"
          expiry_date = (DateTime.parse(subscribe_date).next_year).strftime('%d-%m-%Y %H:%M:%S')
      end
      expiry_date
  end

    def find_member
      @member = Member.find(params[:id])
    end

    def get_paystack_object
      @paystackObj = Paystack.new
    end

    def initiate_paystack_sub
      subscription = PaystackSubscriptions.new(@paystackObj)
    end
   
    def check_paystack_subscription
      @member = Member.find(params[:id].to_i)
      if @member.paystack_subscription_code.nil?
        return false
      else
        paystack_subscription_code = @member.paystack_subscription_code
        subscription = initiate_paystack_sub
        result = subscription.get(paystack_subscription_code)
        if !result.dig('data', 'plan','subscriptions').empty?
          subscription_present =  true
        else
          subscription_present = false
        end
          return subscription_present
      end
    end

    def disable_current_paystack_subscription
      paystack_subscription_code = @member.paystack_subscription_code
      email_token = @member.paystack_email_token
      payload = {
        :code => paystack_subscription_code,
        :token => email_token,
      }
      begin
        uri = URI('https://api.paystack.co/subscription/disable')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json',
                                              'Authorization' => "Bearer #{ENV["PAYSTACK_PRIVATE_KEY"]}" })
        req.body = JSON.generate(payload)
        res = http.request(req)
        result = JSON.parse(res.body)
      rescue => e
          puts "failed #{e}"
          Raven.capture_exception(e)
      end
      return result
    end


    def create_general_transaction(subscribe_date, amount, payment_method)
      GeneralTransaction.create(
          member_fullname: @member.fullname,
          transaction_type: 1,
          subscribe_date: subscribe_date,
          expiry_date: set_expiry_date(subscribe_date),
          staff_responsible: current_user.fullname,
          payment_method: payment_method,
          loyalty_earned: get_loyalty_points(amount),
          loyalty_redeemed: 0,
          membership_plan: retrieve_gym_plan,
          membership_status: 0,
          customer_code: @member.customer_code,
          member_email: @member.email,
          loyalty_type: 1,
          amount: amount )
    end

    def create_attendance_record
      @member.attendance_records.create(
          checkin_date: DateTime.now,
          checkout_date: nil,
          membership_status: @member.account_detail.member_status,
          membership_plan: @member.subscription_plan.plan_name,
          staff_on_duty: current_user.fullname,
           audit_comment: "checked into the gym" )
    end

    def set_paystack_start_date
      start_date = ""
      if @member.subscription_plan.duration == "weekly"
        start_date = date.next_week.strftime('%FT%T%:z').to_s
      elsif @member.subscription_plan.duration == "monthly"
          start_date = date.next_month.strftime('%FT%T%:z').to_s
      elsif @member.subscription_plan.duration == "quarterly"
          start_date = (date + 90.days).strftime('%FT%T%:z').to_s
      elsif @member.subscription_plan.duration == "annually"
          start_date = date.next_year.strftime('%FT%T%:z').to_s
      end
      return start_date
    end

    #Hack to set adjust subscribe start date it falls above 28th of the month
    # Paystack does not permit subscription payment after 28th of every month.
    # customers who walk into the gym after 28th will have their subscription started
    # on the first day of the following month
    def subscribe_date_consistency(date)


    end

    def get_subscription_plan_code
      @member.subscription_plan.paystack_plan_code
    end

    def verify_transaction(reference)
      begin
          uri = URI("https://api.paystack.co/transaction/verify/#{reference}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          req = Net::HTTP::Get.new(uri.path, {
              'Authorization' => "Bearer #{ENV["PAYSTACK_PRIVATE_KEY"]}"
              }
          )
          res = http.request(req)
          subscribe = JSON.parse(res.body)
      rescue => e
          puts "failed #{e}"
      end
    end

    def paystack_subscribe
        options = {
            reference: params[:reference_code],
            member: @member,
            paystack_key: ENV["PAYSTACK_PRIVATE_KEY"],
            staff_name: current_user
        }
        subscribe_status = PaymentProcessing::Subscribe.new(options).paystack_subscribe

        if subscribe_status == 200

            render status: 200, json: {
                message: "success"
            }
        elsif subscribe_status == 400

            render  status: 400, json: {
                message: "Transaction vertification with Paystack failed"
            }
        elsif subscribe_status == 500

            render status: 400, json: {
                message: "failed to enable subscription"
            }
        end

    end



    def member_params
        params.require(:member)
            .permit( :id,
                    :email,
                    :start_date,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :image,
                    :phone_number, 
                    :address, 
                    :date_of_birth,
                    :health_condition_ids, 
                    :next_of_kin_name, 
                    :next_of_kin_phone, 
                    :next_of_kin_email, 
                    :customer_code,
                    :subscription_plan_id,
                    :payment_method_id,
                    :fitness_goal_id,
                    cash_transactions_attributes: [:amount_received, :_destroy],
                    pos_transactions_attributes:[:transaction_reference, :transaction_success, :_destroy] )
    end

end