class AddPaystackPlanIdToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :subscription_plans, :paystack_plan_id, :integer
  end
end
