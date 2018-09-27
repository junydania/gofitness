class ChangeUserPhoneField < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :phone_number, :integer
    add_column :users, :phone_number, :bigint
  end
end
