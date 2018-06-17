class AddMemberIdToCashTransaction < ActiveRecord::Migration[5.1]
  def change
    add_reference :cash_transactions, :member, index: true
  end
  
end
