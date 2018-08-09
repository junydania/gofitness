class Admin::SubscriptionPlansController < ApplicationController

    helper ApplicationHelper

    before_action :authenticate_user!
    
    
    def index
        @subscription_plans = SubscriptionPlan.all
    end


    def new
        @subscription_plan = SubscriptionPlan.new
        @feature = Feature.new
    end

    def show
        @subscription_plan = SubscriptionPlan.find(params[:id])
    end


    def create
        if plan_param[:recurring] == "true"
            result = create_paystack_plan(plan_param)
            if result["status"] == true
                paystack_plan_code = result["data"]["plan_code"]
                @subscription_plan = SubscriptionPlan.create(plan_param)
                @subscription_plan.update_attribute(:paystack_plan_code, paystack_plan_code)
                    flash[:notice] = "New Plan Successfully Created in System & Paystack"
                    redirect_to new_admin_subscription_plan_path
            else 
                flash[:notice] = "Check to ensure the form is properly filled"
                redirect_to new_admin_subscription_plan_path
            end
        else
            @subscription_plan = SubscriptionPlan.new(plan_param)
            if @subscription_plan.save
                flash[:notice] = "New Plan Successfully Created in the System"
                redirect_to new_admin_subscription_plan_path
            else
                flash[:notice] = "Error creating new record! Check to ensure all fields are filled"
                redirect_to new_admin_subscription_plan_path
            end
        end
    end



    private

    def instantiate_paystack
        paystackObj = Paystack.new
        return paystackObj
    end  

    def create_paystack_plan(plan_param)
        paystackObj = instantiate_paystack
        plans = PaystackPlans.new(paystackObj)
        data = {
                :name => plan_param[:plan_name],
                :description =>  plan_param[:description],
                :amount => plan_param[:cost].to_i * 100,
                :interval => plan_param[:duration],
                :currency => "NGN"
        }
        result = plans.create(data)
        return result
    end

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
