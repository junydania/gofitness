class SubscriptionHistory < ApplicationRecord
   
    belongs_to :member
    
    enum subscription_type: [:registration, :renewal]
    enum member_status: [:active, :deactivated]
    
end
