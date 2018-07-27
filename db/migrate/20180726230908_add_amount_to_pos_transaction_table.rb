class AddAmountToPosTransactionTable < ActiveRecord::Migration[5.1]
  def change
    add_column  :pos_transactions,  :amount_received, :integer
  end
end
