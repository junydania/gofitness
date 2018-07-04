class ChangeMemberStatusinAccountDetail < ActiveRecord::Migration[5.1]
  def change
    remove_column :account_details, :member_status, :string
    add_column :account_details, :member_status, :integer
  end
end
