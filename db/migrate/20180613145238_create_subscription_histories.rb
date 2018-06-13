class CreateSubscriptionHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_histories do |t|
      t.datetime :subscribe_date
      t.datetime :expiry_date
      t.string :subscription_type
      t.string :subscription_plan
      t.integer :amount
      t.string :payment_method
      t.string :member_status
      t.string :subscription_status

      t.timestamps
    end
  end
end
