class SubscriptionPlan < ApplicationRecord

    enum duration: [:daily, :monthly, :bimonthly, :quarterly, :semiannual, :yearly]
    validates_presence_of   :plan_name, :cost, :duration, :description, :group_plan, :no_of_group_members
    
end


