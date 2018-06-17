class AddReferenceToAccountDetail < ActiveRecord::Migration[5.1]
  def change
    add_reference :account_details, :member, index: true
  end
end
