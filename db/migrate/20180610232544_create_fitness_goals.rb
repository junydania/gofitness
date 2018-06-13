class CreateFitnessGoals < ActiveRecord::Migration[5.1]
  def change
    create_table :fitness_goals do |t|
      t.string :goal_name

      t.timestamps
    end
  end
end
