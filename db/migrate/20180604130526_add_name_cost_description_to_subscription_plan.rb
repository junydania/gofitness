class AddNameCostDescriptionToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :subscription_plans, :plan_name, :string
    add_column :subscription_plans, :cost, :integer
    add_column :subscription_plans, :description, :string
    add_column :subscription_plans, :duration, :integer
    add_column :subscription_plans, :group_plan, :boolean
    add_column :subscription_plans, :no_of_group_members, :integer
  end
end
