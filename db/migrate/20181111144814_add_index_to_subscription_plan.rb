class AddIndexToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_index :subscription_plans, :paystack_plan_code
  end
end
