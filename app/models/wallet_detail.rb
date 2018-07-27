class WalletDetail < ApplicationRecord
    belongs_to  :member
    enum wallet_status: [:active, :inactive]
    
end
