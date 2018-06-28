class AccountDetail < ApplicationRecord
    
    belongs_to :member

    enum member_status: [:active, :deactivated]

end
