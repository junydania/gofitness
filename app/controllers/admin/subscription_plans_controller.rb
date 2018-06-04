class Admin::SubscriptionPlansController < ApplicationController

    def new
        @subscription_plan = SubscriptionPlan.new
    end

end
