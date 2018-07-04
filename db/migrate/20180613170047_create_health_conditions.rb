class CreateHealthConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :health_conditions do |t|
      t.string :condition_name

      t.timestamps
    end
  end
end
