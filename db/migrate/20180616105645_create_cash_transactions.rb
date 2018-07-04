class CreateCashTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :cash_transactions do |t|
      t.integer :amount_received
      t.string :cash_received_by
      t.string :service_paid_for

      t.timestamps
    end
  end
end
