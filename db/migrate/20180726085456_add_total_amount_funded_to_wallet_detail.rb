class AddTotalAmountFundedToWalletDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :wallet_details, :total_amount_funded, :integer
    remove_column :wallet_details, :amount_used, :integer
    add_column  :wallet_details,  :total_amount_used, :integer
  end
end
