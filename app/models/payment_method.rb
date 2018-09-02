class PaymentMethod < ApplicationRecord
    
    has_many :members
    validates_presence_of :payment_system, :discount

    def self.options_for_select
        order('LOWER(payment_system)').map { |e| [e.payment_system, e.id]}
    end
end
