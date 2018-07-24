class AddGymCheckedIntoAccountDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :account_details, :gym_attendance_status, :integer, default: 0
  end
end
