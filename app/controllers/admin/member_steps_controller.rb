class Admin::MemberStepsController < ApplicationController

    require 'paystack_module'  
    require 'rest-client'

    include Wicked::Wizard
    include GoFitPaystack

    before_action :authenticate_user!
    before_action :get_paystack_object, only: [:paystack_subscribe]
    before_action :find_member
    steps :payment, :personal_profile, :next_of_kin, :image_capture


    def show
        gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
        gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
        gon.publicKey = ENV["PAYSTACK_TEST_PUBLIC"]
        render_wizard
    end

    def update
        case step
        when :payment
            if @member.payment_method.payment_system == "Cash"
                @member.cash_transactions.build({cash_received_by: current_user.fullname, 
                                                service_paid_for: "Gym Membership",
                                                amount_received: member_params[:cash_transactions_attributes]["0"][:amount_received]} )
                @member.save   
            elsif @member.payment_method.payment_system == "POS Terminal"
                @member.pos_transactions.build({
                        transaction_success: "success", 
                        transaction_reference: "Gym Membership",
                        processed_by: current_user.fullname } )
                @member.save   
            else
                skip_step
            end
            render_wizard @member
            
        when :personal_profile
            customer_code = member_params[:customer_code]
            check_code = Member.find_by(customer_code: customer_code)
            if check_code.nil? == true
                @member.update_attributes(member_params)
                render_wizard @member
            else 
                render_wizard
            end
        when :next_of_kin
            @member.update_attributes(member_params)
            render_wizard @member
        end
    end

    
    def finish_wizard_path
        member_profile_path(@member)
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


    def paystack_subscribe
        reference = params[:reference_code]
        transactions = PaystackTransactions.new(@paystackObj)
        result = transactions.verify(reference)
        if result["status"] == true     
            @auth_code = result["data"]["authorization"]["authorization_code"]
            @paystack_customer_code = result["data"]["customer"]["customer_code"]
            @start_date, @plan_code = set_paystack_start_date, get_subscription_plan_code
            @create_subscription = PaystackSubscriptions.new(@paystackObj)
            subscribe = @create_subscription.create(  customer: @paystack_customer_code,
                                                      plan: @plan_code,
                                                      authorization: @auth_code,
                                                      start_date: @start_date )
            if subscribe["status"] == true
                subscription_code = subscribe["data"]["subscription_code"]
                email_token = subscribe["data"]["email_token"]
                paystack_created_date = subscribe["data"]["createdAt"]
                enable_subscription = @create_subscription.enable(code: subscription_code, token: email_token)
                subscribe_date = Time.iso8601(paystack_created_date).strftime('%d-%m-%Y %H:%M:%S')
                expiry_date = set_expiry_date(subscribe_date)
                if enable_subscription["status"] == true
                    account_update = update_account_detail(subscribe_date, expiry_date)
                    if account_update.save?
                        create_subscription_history(subscribe_date, expiry_date)
                        create_loyalty_history(amount)
                        create_general_transaction(subscribe_date, amount)    
                    end
                end
            end
            render status: 200, json: {
                message: "success"
            }
        else
            render  status: 400, json: { 
                success: false 
            }
        end    
    end
    

   
    private

    def find_member
        @member = Member.find(session[:member_id]) 
    end

    def update_account_detail(subscribe_date, expiry_date, amount)
        account_update = @member.build_account_detail(
                                    subscribe_date:subscribe_date,
                                    expiry_date: expiry_date,
                                    member_status: 1,
                                    amount: retrieve_amount,
                                    loyalty_points_balance: get_loyalty_points(amount),
                                    loyalty_points_used: 0,
                                    gym_plan: retrieve_gym_plan,
                                    recurring_billing: true )
    end

    
    def create_loyalty_history(amount)
        points = get_loyalty_points(amount)
        loyalty_history = @member.create_loyalty_history(
            points_earned: points,
            points_redeemed: 0,
            loyalty_transaction_type: "New Registration",
            loyalty_balance: points )
    end


    def get_loyalty_points(amount)
        point = Loyalty.find_by(loyalty_type: "register").loyalty_points_percentage
        point = ((point * 0.01) * amount).to_i
    end

    
    def loyalty_current_balance
        @member.account_detail.loyalty_points_balance
    end
    
    
    def retrieve_payment_method
        @member.payment_method.payment_system
    end

    
    def create_subscription_history(subscribe_date, expiry_date)
        subscription_history = @member.create_subscription_history(
            subscribe_date: subscribe_date,
            expiry_date: expiry_date,
            subscription_type: 1,
            subscription_plan: retrieve_gym_plan,
            amount: retrieve_amount,
            payment_method: retrieve_payment_method,
            member_status: 1,
            subscription_status: "Paid"
        )
    end


    def retrieve_amount
        amount = @member.subscription_plan.cost
    end

    
    def retrieve_gym_plan
        plan = @member.subscription_plan.plan_name
    end


    def set_expiry_date(subscribe_date)
        expiry_date = String.new
        if @member.subscription_plan.duration == "monthly"
            expiry_date =  (DateTime.parse(subscribe_date) + 30).strftime('%d-%m-%Y %H:%M:%S')
        elsif @member.subscription_plan.duration == "quarterly"
            expiry_date =  (DateTime.parse(subscribe_date) + 90).strftime('%d-%m-%Y %H:%M:%S')
        elsif @member.subscription_plan.duration == "annually"
            expiry_date = (DateTime.parse(subscribe_date).next_year).strftime('%d-%m-%Y %H:%M:%S')
        end
        expiry_date
    end

    def set_paystack_start_date
        start_date = String.new
        if @member.subscription_plan.duration == "monthly"
            start_date = DateTime.now.next_month.to_s
        elsif @member.subscription_plan.duration == "quarterly"
            start_date = (DateTime.now + 90).to_s
        elsif @member.subscription_plan.duration == "annually"
            start_date = DateTime.now.next_year.to_s
        end
        start_date
    end
 
    def get_subscription_plan_code
        @member.subscription_plan.paystack_plan_code
    end


    def get_paystack_object
        @paystackObj = GoFitPaystack.instantiate_paystack
    end

    def create_general_transaction(subscribe_date, amount, payment_method)
        GeneralTransaction.create(
            member_fullname: @member.fullname,
            transaction_type: 1,
            subscribe_date: subscribe_date,
            expiry_date: set_expiry_date(subscribe_date),
            staff_responsible: current_user.fullname,
            payment_method: payment_method,
            loyalty_earned: get_loyalty_points(amount)
            loyalty_redeemed: 0,
            membership_plan: retrieve_gym_plan
            membership_status: 1,
            customer_code: @member.customer_code
            member_email: @member.email,
            loyalty_type: 1,
            amount: amount )
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
