class CreatePosTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :pos_transactions do |t|
      t.boolean :transaction_success
      t.string :transaction_reference
      t.string :processed_by

      t.timestamps
    end
  end
end
