class CreateOneOffRevenues < ActiveRecord::Migration[5.1]
  def change
    create_table :one_off_revenues do |t|
      t.string :name
      t.decimal :amount

      t.timestamps
    end
  end
end
