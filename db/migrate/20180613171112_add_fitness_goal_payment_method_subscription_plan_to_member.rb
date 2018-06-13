class AddFitnessGoalPaymentMethodSubscriptionPlanToMember < ActiveRecord::Migration[5.1]
  def change
    add_reference :members, :fitness_goal, index: true, foreign_key: true
    add_reference :members, :payment_method, index: true, foreign_key: true
    add_reference :members, :subscription_plan, index: true, foreign_key: true
  end
end
