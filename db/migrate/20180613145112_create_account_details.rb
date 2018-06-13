class CreateAccountDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :account_details do |t|
      t.datetime :subscribe_date
      t.datetime :expiry_date
      t.string :member_status
      t.datetime :pause_start_date
      t.datetime :pause_cancel_date
      t.integer :amount
      t.integer :loyalty_points_used
      t.integer :loyalty_points_balance
      t.string :gym_plan
      t.boolean :recurring_billing

      t.timestamps
    end
  end
end
