class CreateSubscriptionPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_plans do |t|

      t.timestamps
    end
  end
end
