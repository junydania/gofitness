class AddPauseCountToAccountDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :account_details, :pause_permit_count, :integer, default: 0
  end
end
