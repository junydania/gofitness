class Admin::MemberStepsController < ApplicationController

    before_action :authenticate_user!
    require 'paystack_module'  
    require 'rest-client'

    include Wicked::Wizard
    include GoFitPaystack

    before_action :get_paystack_object, only: [:paystack_customer_subscribe]
    before_action :find_member, only: [:show, :update, :upload_image]

    steps :payment, :personal_profile, :next_of_kin

    def show
        gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
        gon.lastName, gon.displayValue, gon.publicKey = @member.last_name, @member.phone_number, ENV["PAYSTACK_TEST_PUBLIC"]
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

        when :personal_profile
            @member.update_attributes(member_params)

        when :next_of_kin
            
        end
        
        render_wizard @member
    end


    def upload_image
        member_image = Shrine.data_uri(params[:image])
        @member.image = member_image
    end

    
    def paystack_customer_subscribe
        reference = params[:reference_code]
        transactions = PaystackTransactions.new(@paystackObj)
        result = transactions.verify(reference)
        if result["status"] == true     
            @auth_code = result["data"]["authorization"]["authorization_code"]
            @customer_code = result["data"]["customer"]["customer_code"]
            member_id = session[:member_id]
            @member = Member.find(member_id)
            start_date = nil
            if @member.subscription_plan.duration == "monthly"
                start_date = DateTime.now.next_month.to_s
            elsif @member.subscription_plan.duration == "quarterly"
                start_date = (DateTime.now + 90).to_s
            elsif @member.subscription_plan.duration == "annually"
                start_date = DateTime.now.next_year.to_s
            end
            @plan_code = @member.subscription_plan.paystack_plan_code
            @create_subscription = PaystackSubscriptions.new(@paystackObj)
            subscribe = @create_subscription.create(  customer: @customer_code,
                                                      plan: @plan_code,
                                                      authorization: @auth_code,
                                                      start_date: start_date )
            if subscribe["status"] == true
                subscription_code = subscribe["data"]["subscription_code"]
                email_token = subscribe["data"]["email_token"]
                enable_subscription = @create_subscription.enable(code: subscription_code, token: email_token)
                if enable_subscription["status"] == true
                    ## Feature to Update AccountDetail, LoyaltyHistory, PaystackTransactions, SubscriptionHistory, GeneralTransactions.
                    render json: {
                        message: "success"
                    }
                end
            end
        end    
    end
    

    # def paystack_customer_subscribe
    #     render json: {
    #         message: "success"
    #     } 
    # end
    

    private

    def update_account_detail
    end

    def update_loyalty_history
    end

    def update_subscription_history
    end

    def update_general_transactions
    end


    def verify_payment
        
    end

    def get_paystack_object
        @paystackObj = GoFitPaystack.instantiate_paystack
    end

    def find_member
        member_id = session[:member_id]
        @member = Member.find(member_id) 
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
                    health_condition_ids: [],
                    pos_transactions_attributes: [:transaction_success, :transaction_reference, :processed_by, :_destroy],
                    cash_transactions_attributes: [:amount_received, :cash_received_by, :service_paid_for, :_destroy]
            )
    end

end
