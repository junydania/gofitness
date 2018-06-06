FactoryBot.define do
  factory :subscription_plan do
    plan_name "Entry Package"
    cost 2000
    description "Go fitness Daily package"
    group_plan :false
    no_of_group_members 0
    duration { SubscriptionPlan.duration.keys.sample }
  end
end
