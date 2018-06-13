class CreateMemberHealthConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :member_health_conditions do |t|
      t.references :member, foreign_key: true
      t.references :health_condition, foreign_key: true
      
      t.timestamps
    end
  end
end
