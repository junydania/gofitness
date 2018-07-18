class Admin::MembersController < Devise::RegistrationsController
    
    prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
    before_action :authenticate_user!
    before_action :find_member, only: [:renew_membership, :pos_renewal, :cash_renewal, :check_paystack_subscription, :unsubscribe_membership ]
    before_action :get_paystack_object, only: [:check_paystack_subscription, :paystack_renewal, :initiate_paystack_sub, :unsubscribe_membership]

    require 'securerandom'


    def index
      @members = Member.all
    end

    def new
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      build_resource
      yield resource if block_given?
      respond_with resource
    end

    def edit
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      render :edit
    end

    def show
      @member = Member.find(params[:id])
    end


    def create
        new_params = member_params.clone
        new_params[:password] = SecureRandom.hex(7)
        new_params[:password_confirmation] = new_params[:password]
        ## Implement feature to mail login address and password to new member
        build_resource(new_params)
        if resource.save
          session[:member_id] = resource.id
          flash[:notice] = "Receive Payment & Complete the Registration Process"
          redirect_to admin_member_steps_path
        else
          clean_up_passwords resource
          respond_with resource
        end
    end

    def renew_membership
      gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
      gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
      gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
      gon.member_id = @member.id
      session[:member_id] = @member.id
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
        if @member.account_detail.pause_count < 2
          pause_subscription_steps
        else
          render status: 401, json: {
            message: "pause exceeded"
          }
        end
     when "quarterly"
        if @member.account_detail.pause_count < 3
          pause_subscription_steps
        else
          render status: 401, json: {
            message: "pause exceeded"
          }
        end
     when "annually"
        if @member.account_detail.pause_count < 5
          pause_subscription_steps
        else
          render status: 401, json: {
            message: "pause exceeded"
          }
        end
      end
    end


    private

    def true?(obj)
      obj.to_s == "true"
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
        render status: 401, json: {
          message: "no subscription"
        }
      end
    end

    def create_pause_history
      @member.pause_histories.create(
        pause_start_date: @member.account_detail.pause_start_date,
        pause_cancel_date: @member.account_detail.pause_cancel_date,
        paused_by: current_user.fullname)
    end

    def update_pause_account_detail
        @member.account_detail.pause_count = @member.account_detail.pause_count + 1
        @member.account_detail.pause_start_date = DateTime.now
        @member.account_detail.pause_cancel_date = DateTime.now + 7
        @member.account_detail.member_status = 2
        @member.save
    end

    def update_all_records(subscribe_date, expiry_date, recurring, amount, payment_method, subscription_status)
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
                                      processed_by: current_user.fullname )
      return pos_transaction
    end


    def create_cash_transaction(cash_received)
        cash_transaction = @member.cash_transactions.create(
                                        amount_received: cash_received,
                                        cash_received_by: current_user.fullname,
                                        service_paid_for: "Membership Renewal",
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
                                  loyalty_points_balance: update_loyalty_points(amount),
                                  loyalty_points_used: 0,
                                  gym_plan: retrieve_gym_plan,
                                  recurring_billing: recurring )
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
          subscription_status: subscription_status )
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
          loyalty_balance: update_loyalty_points(amount) )
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
      if @member.subscription_plan.duration == "monthly"
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
        subscription_present =  result['status']
        subscription = true?(subscription_present)
        return subscription
      end
    end

    def disable_current_paystack_subscription
      paystack_subscription_code = @member.paystack_subscription_code, 
      email_token = @member.paystack_email_token
      subscription = initiate_paystack_sub
      result = subscription.disable(
				:code => paystack_subscription_code,
				:token => email_token )
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

    def set_paystack_start_date
      start_date = ""
      if @member.subscription_plan.duration == "monthly"
          start_date = DateTime.now.next_month.to_s
      elsif @member.subscription_plan.duration == "quarterly"
          start_date = (DateTime.now + 90).to_s
      elsif @member.subscription_plan.duration == "annually"
          start_date = DateTime.now.next_year.to_s
      end
      return start_date
    end

    def get_subscription_plan_code
      @member.subscription_plan.paystack_plan_code
    end

    def paystack_subscribe
      reference = params[:reference_code]
      transactions = PaystackTransactions.new(@paystackObj)
      result = transactions.verify(reference)
      if result["status"] == true     
          auth_code = (result["data"]["authorization"]["authorization_code"]).to_s
          paystack_customer_code = (result["data"]["customer"]["customer_code"]).to_s
          start_date, plan_code = set_paystack_start_date.to_s, get_subscription_plan_code.to_s, 
          create_subscription = PaystackSubscriptions.new(@paystackObj)
          subscribe = create_subscription.create(customer: paystack_customer_code,
                                                  plan: plan_code,
                                                  authorization: auth_code,
                                                  start_date: start_date,
                                                 )
          if subscribe["status"] == true
              subscription_code = subscribe["data"]["subscription_code"]
              email_token = subscribe["data"]["email_token"]
              @member.update(paystack_subscription_code: subscription_code,
                             paystack_email_token: email_token)
              paystack_created_date = subscribe["data"]["createdAt"]
              enable_subscription = create_subscription.enable(code: subscription_code, token: email_token)
              subscribe_date = Time.iso8601(paystack_created_date).strftime('%d-%m-%Y %H:%M:%S')
              expiry_date, amount = set_expiry_date(subscribe_date), retrieve_amount
              recurring, subscription_status = true, 0
              payment_method = retrieve_payment_method
              if enable_subscription["status"] == true
                  update_all_records(subscribe_date, expiry_date, recurring, amount, payment_method, subscription_status)
                  render status: 200, json: {
                    message: "success"
                }    
              end
          end
      else
          render  status: 400, json: { 
              success: false 
          }
      end    
    end


    def member_params
        params.require(:member)
            .permit( :id,
                    :email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :image,
                    :subscription_plan_id,
                    :payment_method_id,
                    :fitness_goal_id,
                    cash_transactions_attributes: [:amount_received, :_destroy],
                    pos_transactions_attributes:[:transaction_reference, :transaction_success, :_destroy] )
    end


end
