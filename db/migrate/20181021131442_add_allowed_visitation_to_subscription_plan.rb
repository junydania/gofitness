class AddAllowedVisitationToSubscriptionPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :subscription_plans, :allowed_visitation_count, :string, default: 'unlimited'
  end
end