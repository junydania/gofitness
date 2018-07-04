class GeneralTransaction < ApplicationRecord

    enum transaction_type: [:registration, :renewal]
    enum loyalty_type: [:register, :renew, :referal]
    enum member_status: [:active, :deactivated]

end

