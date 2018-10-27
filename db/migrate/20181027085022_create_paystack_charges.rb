class CreatePaystackCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :paystack_charges do |t|
      t.datetime :paid_at
      t.string :plan
      t.integer :amount
      t.string :channel
      t.references :member, foreign_key: true

      t.timestamps
    end
  end
end
