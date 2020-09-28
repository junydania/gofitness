class ChangeOneOffRevenueAmountType < ActiveRecord::Migration[5.1]
  def change
    change_column :one_off_revenues, :amount, :integer
  end
end
