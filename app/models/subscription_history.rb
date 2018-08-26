class SubscriptionHistory < ApplicationRecord
   
    audited
    
    belongs_to :member
    
    enum subscription_type: [:registration, :renewal, :deactivation]
    enum member_status: [:active, :deactivated]
    enum subscription_status: [:paid, :unpaid]

end
