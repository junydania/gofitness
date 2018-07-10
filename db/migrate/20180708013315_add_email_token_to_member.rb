class AddEmailTokenToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :paystack_email_token, :string
  end
end
