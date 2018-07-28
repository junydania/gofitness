class RemoveAmountLastUsedFromAccountDetail < ActiveRecord::Migration[5.1]
  def change
    remove_column :wallet_details, :amount_last_used, :integer
    remove_column :wallet_histories, :amount_last_used, :integer
  end
end
