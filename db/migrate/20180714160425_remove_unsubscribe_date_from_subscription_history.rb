class RemoveUnsubscribeDateFromSubscriptionHistory < ActiveRecord::Migration[5.1]
  def change
    remove_column :subscription_histories, :deactivation_date, :string
    add_column :account_details, :unsubscribe_date, :integer
  end
end
