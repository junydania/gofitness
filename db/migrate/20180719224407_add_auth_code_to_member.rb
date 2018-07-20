class AddAuthCodeToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :paystack_auth_code, :string
  end
end
