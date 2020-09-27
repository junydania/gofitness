class ChangeOneOffCostNameFieldType < ActiveRecord::Migration[5.1]
  def change
    change_column :one_off_revenues, :cost_type, :integer, using: 'cost_type::integer'
  end
end
