class ChangeFieldsinSubscriptionHistory < ActiveRecord::Migration[5.1]
  def change
    remove_column :subscription_histories, :subscription_type, :string
    add_column :subscription_histories, :subscription_type, :integer
    remove_column :subscription_histories, :member_status, :string
    add_column :subscription_histories, :member_status, :integer
  end
end
