class SubscriptionPlan < ApplicationRecord

    has_many :subscription_plan_features
    has_many :features, through: :subscription_plan_features

    enum duration: [:daily, :monthly, :bimonthly, :quarterly, :semiannual, :yearly]
    validates_presence_of   :plan_name, :cost, :duration, :description
    validates :group_plan, :inclusion => {:in => [true, false]}
    validates :no_of_group_members, presence: true, if: :group_plan?
    
end


