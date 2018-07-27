class CreateWalletDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :wallet_details do |t|
      t.integer :current_balance
      t.integer :amount_last_funded
      t.integer :amount_used
      t.integer :amount_last_used
      t.datetime :wallet_expiry_date
      t.integer :member_id
      t.datetime :date_last_funded
      t.integer  :wallet_status
      
      t.timestamps
    end
  end
end
