class AddReferenceToSubscriptionHistory < ActiveRecord::Migration[5.1]
  def change
    add_reference :subscription_histories, :member, index: true
  end
end
