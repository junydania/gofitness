class SubscriptionPlanFeature < ApplicationRecord
  belongs_to :subscription_plan
  belongs_to :feature
  has_many :members
end

