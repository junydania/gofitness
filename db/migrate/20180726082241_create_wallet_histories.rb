class CreateWalletHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :wallet_histories do |t|
      t.integer :amount_paid_in
      t.integer :wallet_previous_balance
      t.integer :amount_used
      t.string :processed_by
      t.integer :wallet_new_balance
      t.integer :amount_last_used
      t.integer :member_id

      t.timestamps
    end
  end
end
