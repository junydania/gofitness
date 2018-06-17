class AddLoyaltyBalanceToLoyaltyHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :loyalty_histories, :loyalty_balance, :integer
    remove_column :loyalty_histories, :loyalty_activity_type, :string
    add_column :loyalty_histories, :loyalty_transaction_type, :integer
    add_reference :loyalty_histories, :member, index: true
    add_index :loyalty_histories, :loyalty_balance
    add_index :loyalty_histories, :loyalty_transaction_type
  end
end
