class Admin::MemberStepsController < ApplicationController
    require 'paystack_module'  
    require 'rest-client'

    include Wicked::Wizard
    include GoFitPaystack

    before_action :get_paystack_object, only: [:paystack_customer_subscribe]
    before_action :find_member, only: [:show, :update]

    steps :payment, :personal_profile, :next_of_kin

    def show
        gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
        gon.lastName, gon.displayValue, gon.publicKey = @member.last_name, @member.phone_number, ENV["PAYSTACK_TEST_PUBLIC"]
        render_wizard
    end

    def update
        @member.attributes = params[:member]
        render_wizard @member
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
                enable_subscription = @create_subscription.enable(:code => subscription_code, :token => email_token)
                if enable_subscription["status"] == true
                    render json: {
                        message: "success"
                    }
                end
            end
        end    
    end



    
    private

    def verify_payment
        
    end

    def get_paystack_object
        @paystackObj = GoFitPaystack.instantiate_paystack
    end

    def find_member
        member_id = session[:member_id]
        @member = Member.find(member_id) 
    end





end
