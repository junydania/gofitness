class LoyaltyHistory < ApplicationRecord

    audited associated_with: :member

    belongs_to :member
    enum loyalty_transaction_type: [:registration, :renewal]
end
