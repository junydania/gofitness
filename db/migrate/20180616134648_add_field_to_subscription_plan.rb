class AddFieldToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :subscription_plans, :recurring, :boolean
  end
end
