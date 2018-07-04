class CreateLoyalties < ActiveRecord::Migration[5.1]
  def change
    create_table :loyalties do |t|
      t.integer :loyalty_type
      t.integer :loyalty_points_percentage

      t.timestamps
    end
  end
end
