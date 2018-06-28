class GeneralTransaction < ApplicationRecord

    enum transaction_type: [:registration, :renewal]
    enum loyalty_type: [:register, :renewal, :referal]
    enum payment_method: [:paystack, :pos, :cash]
    enum member_status: [:active, :deactivated]

end

