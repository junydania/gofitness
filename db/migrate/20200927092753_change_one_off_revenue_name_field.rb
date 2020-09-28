class ChangeOneOffRevenueNameField < ActiveRecord::Migration[5.1]
  def change
    rename_column :one_off_revenues, :name, :cost_type
  end
end
