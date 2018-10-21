class AddOrganizationPackageToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :subscription_plans, :organization_package, :integer, default: 0

  end
end
