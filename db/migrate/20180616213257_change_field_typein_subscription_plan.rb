class ChangeFieldTypeinSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    remove_column :subscription_plans, :paystack_plan_id, :integer
    add_column :subscription_plans, :paystack_plan_code, :string
  end
end

