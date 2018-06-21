class ChangeCustomerCodePhoneFieldinMemberTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :members, :customer_code, :integer
    remove_column :members, :phone_number, :integer
    add_column :members, :customer_code, :bigint
    add_column :members, :phone_number, :bigint
    add_index :members, :customer_code, unique: true
    add_index :members, :phone_number
  end
end
