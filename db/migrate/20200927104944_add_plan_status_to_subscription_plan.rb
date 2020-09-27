class AddPlanStatusToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :subscription_plans, :status, :integer, default: 0
  end
end
