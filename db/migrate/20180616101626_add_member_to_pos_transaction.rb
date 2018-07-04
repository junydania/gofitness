class AddMemberToPosTransaction < ActiveRecord::Migration[5.1]
  def change
    add_reference :pos_transactions, :member, index: true
  end
end
