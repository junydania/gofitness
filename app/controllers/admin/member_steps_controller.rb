class Admin::MemberStepsController < ApplicationController

    require 'accounting'
    require 'securerandom'
    require 'payment_processing'

    # load_and_authorize_resource param_method: :member_params

    skip_authorize_resource :only => :paystack_subscribe

    include Wicked::Wizard
    include Accounting
    include PaymentProcessing

    before_action :authenticate_user!
    before_action :find_member
    steps :payment, :personal_profile, :next_of_kin, :image_capture


    def show
        gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
        gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
        gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
        render_wizard
    end

    def update
        case step
        when :payment
            if @member.payment_method.payment_system.upcase == "CASH" ||  @member.payment_method.payment_system.upcase == "MOBILE TRANSFER"
                if  @member.account_detail.member_status != 'active'
                    amount_received = member_params[:cash_transactions_attributes]["0"][:amount_received].to_i
                    expected_amount = retrieve_amount
                    if  amount_received ==  expected_amount
                        @member.cash_transactions.build({cash_received_by: current_user.fullname,
                                                        service_paid_for: "Gym Membership",
                                                        amount_received: amount_received })
                        if @member.save
                            cash_subscribe
                        end
                        render_wizard(@member)
                    else
                        flash[:notice] = "Check to ensure cash received is same as cash expected"
                        redirect_back(fallback_location:  admin_member_step_path)
                    end
                end
            elsif @member.payment_method.payment_system.upcase == "POS TERMINAL" && @member.account_detail.member_status != 'active'
                pos_transaction_status = member_params[:pos_transactions_attributes]["0"]["transaction_success"].to_sym
                if  pos_transaction_status === :true
                    @member.pos_transactions.build({
                            transaction_success: "success",
                            transaction_reference: "Gym Membership",
                            processed_by: current_user.fullname } )
                    if @member.save
                        pos_subscribe
                    end
                    render_wizard(@member)
                else
                    flash[:notice] = "Ensure POS transaction is successful before proceeding"
                    redirect_back(fallback_location:  admin_member_step_path)
                end
            elsif @member.account_detail.member_status == 'active'
                flash[:notice] = "Member already has an active membership"
                skip_step
                render_wizard(@member)
            end

        when :personal_profile
            customer_code = member_params[:customer_code]
            check_code = Member.find_by(customer_code: customer_code)
            if check_code.nil? == true && @member.customer_code.nil?
                updated_member_params = member_params
                updated_member_params["date_of_birth"] = updated_member_params["date_of_birth"].empty? ? nil: Date.strptime(updated_member_params["date_of_birth"], '%m/%d/%Y').to_datetime
                begin
                    @member.update_attributes(updated_member_params)
                    render_wizard @member
                rescue ActiveRecord::RecordNotUnique => e
                    flash[:notice] = "Ensure phone number is unique"
                    render_wizard    
                end

            elsif !@member.customer_code.nil?
                flash[:notice] = "Member already has a registered code! Update other records"
                skip_step
                render_wizard(@member)
            else 
                flash[:notice] = "Customer Code already exists in the system"
                render_wizard
            end

        when :next_of_kin
            @member.update_attributes(member_params)
            render_wizard @member
        end
        
    end

    def finish_wizard_path
        member_profile_path(@member)
        # session.delete(:member_id)
    end


    def upload_image
        member_image = Shrine.data_uri(params[:image])
        @member.image = member_image
        if @member.save
            render json: {
                message: "Image Uploaded"
            } 
        else
            render status: 500, json: {
                message: "Failed to Upload"
            }
        end
    end


    def cash_subscribe
        subscribe_date = set_subscribe_date
        expiry_date = set_expiry_date(subscribe_date)
        create_charge
        account_update = update_account_detail(subscribe_date, expiry_date)
        amount, payment_method, subscription_status = retrieve_amount, retrieve_payment_method, 0
        if account_update.save
            subscription_history_options = {
                subscribe_date: subscribe_date,
                expiry_date: expiry_date,
                amount: amount,
                payment_method: payment_method,
                member: @member,
                staff_name: current_user,
                subscription_status: subscription_status }
            PaymentProcessing::Subscribe.new(subscription_history_options).update_subscription_histories
            options = {"description": 'New Subscription', "amount": amount}
            Accounting::Entry.new(options).cash_entry
        end
    end

    def pos_subscribe
        subscribe_date = set_subscribe_date
        expiry_date = set_expiry_date(subscribe_date)
        create_charge
        account_update = update_account_detail(subscribe_date, expiry_date)
        amount, payment_method = retrieve_amount, retrieve_payment_method
        subscription_status = 0
        if account_update.save
            subscription_history_options = {
                subscribe_date: subscribe_date,
                expiry_date: expiry_date,
                amount: amount,
                payment_method: payment_method,
                member: @member,
                staff_name: current_user,
                subscription_status: subscription_status }
            options = {"description": 'New Subscription', "amount": amount}
            Accounting::Entry.new(options).card_entry
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



    private

    def find_member
        @member = Member.find(session[:member_id])
    end

    def update_account_detail(subscribe_date, expiry_date)
        amount = retrieve_amount
        account_update = @member.build_account_detail(
                                    subscribe_date:subscribe_date,
                                    expiry_date: expiry_date,
                                    member_status: 0,
                                    amount: amount,
                                    loyalty_points_balance: get_loyalty_points(amount),
                                    loyalty_points_used: 0,
                                    gym_plan: retrieve_gym_plan,
                                    recurring_billing: true,
                                    gym_attendance_status: 1,
                                    audit_comment: "paid for new membership plan" )
    end


    def get_loyalty_points(amount)
        point = Loyalty.find_by(loyalty_type: "register").loyalty_points_percentage ||= 15
        point = ((point * 0.01) * amount).to_i
    end

    def loyalty_current_balance
        @member.account_detail.loyalty_points_balance
    end
        
    def retrieve_payment_method
        @member.payment_method.payment_system
    end

    def create_charge
        charge = @member.charges.new(service_plan: retrieve_gym_plan,
                                    amount: retrieve_amount,
                                    payment_method: retrieve_payment_method,
                                    duration: @member.subscription_plan.duration,
                                    gofit_transaction_id: SecureRandom.hex(4)
                                    )
        if charge.save
            MemberMailer.new_subscription(@member).deliver_later
        end

    end

    def retrieve_amount
        amount = @member.subscription_plan.cost
    end

    def retrieve_gym_plan
        plan = @member.subscription_plan.plan_name
    end


    def set_subscribe_date
        ## Hack to set start date for renewals
        if @member.account_detail.created_at < DateTime.now - 1.day
            date = DateTime.now
        else
            date = @member.account_detail.subscribe_date
        end
        return date
    end

    def set_expiry_date(subscribe_date)
        if @member.subscription_plan.duration == "daily"
            expiry_date =  (subscribe_date + 1.day).strftime('%d-%m-%Y %H:%M:%S')
        elsif @member.subscription_plan.duration == "weekly"
            expiry_date =  (subscribe_date + 7.days).strftime('%d-%m-%Y %H:%M:%S')
        elsif @member.subscription_plan.duration == "monthly"
            expiry_date =  (subscribe_date + 30.days).strftime('%d-%m-%Y %H:%M:%S')
        elsif @member.subscription_plan.duration == "quarterly"
            expiry_date =  (subscribe_date + 90.days).strftime('%d-%m-%Y %H:%M:%S')
        elsif @member.subscription_plan.duration == "annually"
            expiry_date =  (subscribe_date.next_year).strftime('%d-%m-%Y %H:%M:%S')
        end
        expiry_date
    end


    def member_params
        params.require(:member)
            .permit(:email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :subscription_plan_id,
                    :payment_method_id,
                    :fitness_goal_id,
                    :customer_code,
                    :phone_number,
                    :address, 
                    :date_of_birth, 
                    :next_of_kin_name,
                    :next_of_kin_phone,
                    :next_of_kin_email,
                    health_condition_ids: [],
                    pos_transactions_attributes: [:transaction_success, :transaction_reference, :processed_by, :_destroy],
                    cash_transactions_attributes: [:amount_received, :cash_received_by, :service_paid_for, :_destroy]
            )
    end
end
