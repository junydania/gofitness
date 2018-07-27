class AddWalletFundMethodToWalletHIstory < ActiveRecord::Migration[5.1]
  def change
    add_column :wallet_histories, :wallet_fund_method, :integer
  end
end

