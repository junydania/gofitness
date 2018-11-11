class AddIndexToPaystackCharges < ActiveRecord::Migration[5.1]
  def change
    add_index :paystack_charges, :created_at
  end
end
