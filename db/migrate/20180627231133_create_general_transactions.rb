class CreateGeneralTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :general_transactions do |t|
      t.string :member_fullname
      t.integer :transaction_type
      t.datetime :subscribe_date
      t.datetime :expiry_date
      t.string :staff_responsible
      t.integer :payment_method
      t.integer :loyalty_earned
      t.integer :loyalty_redeemed
      t.string :membership_plan
      t.integer :membership_status
      t.bigint :customer_code
      t.string :member_email
      t.integer :loyalty_type
      t.integer :amount

      t.timestamps
    end
  end
end
