class AddPaystackSubCodeToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :paystack_subscription_code, :string
  end
end

