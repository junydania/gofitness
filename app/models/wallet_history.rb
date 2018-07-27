class WalletHistory < ApplicationRecord
    belongs_to  :member

    enum wallet_fund_method: [:paystack, :pos, :cash]
    
end 
