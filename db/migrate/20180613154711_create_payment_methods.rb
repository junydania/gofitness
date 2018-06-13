class CreatePaymentMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_methods do |t|
      t.string :payment_system
      t.integer :discount

      t.timestamps
    end
  end
end
