class SubscriptionPlanFeature < ApplicationRecord
  belongs_to :subscription_plan
  belongs_to :feature
end
