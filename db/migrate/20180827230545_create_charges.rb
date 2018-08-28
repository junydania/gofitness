class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges do |t|
      t.string :service_plan
      t.integer :amount
      t.string :payment_method
      t.string :duration
      t.string :gofit_transaction_id
      t.references :member, foreign_key: true
      
      t.timestamps
    end
  end
end
