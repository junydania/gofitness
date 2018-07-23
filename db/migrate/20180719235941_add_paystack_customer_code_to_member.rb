class AddPaystackCustomerCodeToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :paystack_cust_code, :string
  end
end
