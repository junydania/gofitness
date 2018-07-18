class AddDefaultToPauseCountInAccountDetail < ActiveRecord::Migration[5.1]
  def change
    remove_column :account_details, :pause_permit_count, :integer
    add_column :account_details, :pause_permit_count, :integer, default: 0
  end
end
