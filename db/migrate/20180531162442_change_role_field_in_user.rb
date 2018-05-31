class ChangeRoleFieldInUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :role
    add_column :users, :role, :integer, default: 2
    add_index :users, :first_name
    add_index :users, :last_name
  end
end
