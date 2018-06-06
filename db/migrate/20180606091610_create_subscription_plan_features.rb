class CreateSubscriptionPlanFeatures < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_plan_features do |t|
      t.references :subscription_plan, foreign_key: true
      t.references :feature, foreign_key: true

      t.timestamps
    end
  end
end
