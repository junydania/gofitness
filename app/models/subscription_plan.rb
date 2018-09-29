class SubscriptionPlan < ApplicationRecord

    has_many :subscription_plan_features
    has_many :features, through: :subscription_plan_features
    has_many :members

    enum duration: [:daily, :weekly, :monthly, :quarterly, :annually]
    
    validates_presence_of   :plan_name, :cost, :duration, :description
    validates :group_plan, :inclusion => {:in => [true, false]}
    validates :recurring, :inclusion => {:in => [true, false]}
    validates :no_of_group_members, presence: true, if: :group_plan?

    def self.options_for_select
        order('LOWER(plan_name)').map { |e| [e.plan_name, e.id]}
    end
        
end


