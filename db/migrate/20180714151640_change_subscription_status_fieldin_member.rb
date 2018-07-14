class ChangeSubscriptionStatusFieldinMember < ActiveRecord::Migration[5.1]
  def change
    remove_column :subscription_histories, :subscription_status, :string
    add_column :subscription_histories, :subscription_status, :integer
    add_column :subscription_histories, :deactivation_date, :datetime
  end
end
