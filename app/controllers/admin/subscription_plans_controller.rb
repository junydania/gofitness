class Admin::SubscriptionPlansController < ApplicationController

    before_action :authenticate_user!
    
    require 'paystack_module'

    include GoFitPaystack


    def new
        @subscription_plan = SubscriptionPlan.new
        @feature = Feature.new
    end

    def create
        @subscription_plan = SubscriptionPlan.new(plan_param)
        if @subscription_plan.save
            if @subscription_plan.recurring == true
                paystackObj = GoFitPaystack.instantiate_paystack
                plans = PaystackPlans.new(paystackObj)
                data = {
                        :name => @subscription_plan.plan_name,
                        :description =>  @subscription_plan.description,
                        :amount => @subscription_plan.cost * 100,
                        :interval => @subscription_plan.duration,
                        :currency => "NGN"
                }
                @result = plans.create(data)
                if @result["status"] == true
                    paystack_plan_code = @result["data"]["plan_code"]
                    @subscription_plan.update_attribute(:paystack_plan_code, paystack_plan_code)
                    flash[:notice] = "New Plan Successfully Created in System & Paystack"
                    redirect_to new_admin_subscription_plan_path
                else
                    flash[:notice] = "Plan was not successfully created in Paystack"
                    redirect_to new_admin_subscription_plan_path
                end
            else
                flash[:notice] = "New Plan Successfully Created in the System"
                redirect_to new_admin_subscription_plan_path
            end
        else 
            render action: :new
        end
    end
    

    private

    def plan_param
        params.require(:subscription_plan) 
            .permit(:plan_name,
                    :cost,
                    :description,
                    :duration,
                    :group_plan,
                    :recurring,
                    :no_of_group_members,
                    :paystack_plan_code,
                    feature_ids: [] )
    end

end
