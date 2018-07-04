class ChangeNextOfKinMobileAttribute < ActiveRecord::Migration[5.1]
  def change
    remove_column :members, :next_of_kin_phone, :integer
    add_column :members, :next_of_kin_phone, :bigint
  end
end
