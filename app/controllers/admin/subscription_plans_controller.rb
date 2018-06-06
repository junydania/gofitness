class Admin::SubscriptionPlansController < ApplicationController

    def new
        @subscription_plan = SubscriptionPlan.new
        @feature = Feature.new
    end

    def create
        @subscription_plan = SubscriptionPlan.new(plan_param)
        if @subscription_plan.save
            flash[:notice] = "New Plan Successfully Created"
            redirect_to new_admin_subscription_plan_path
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
                    :no_of_group_members)
    end

end
