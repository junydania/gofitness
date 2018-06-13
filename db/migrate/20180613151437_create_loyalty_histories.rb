class CreateLoyaltyHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :loyalty_histories do |t|
      t.integer :points_earned
      t.integer :points_redeemed
      t.string :loyalty_activity_type

      t.timestamps
    end
  end
end
