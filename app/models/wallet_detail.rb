class WalletDetail < ApplicationRecord

    audited associated_with: :member
    
    belongs_to  :member
    enum wallet_status: [:active, :inactive]
    
end
