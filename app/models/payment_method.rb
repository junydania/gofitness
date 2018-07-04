class PaymentMethod < ApplicationRecord
    has_many :members
    validates_presence_of :payment_system, :discount
end
