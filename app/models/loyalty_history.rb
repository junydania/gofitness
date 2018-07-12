class LoyaltyHistory < ApplicationRecord
    belongs_to :member
    enum loyalty_transaction_type: [:registration, :renewal]
end
