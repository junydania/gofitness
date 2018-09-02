class SubscriptionHistory < ApplicationRecord
   
    belongs_to :member
    enum subscription_type: [:registration, :renewal, :deactivation]
    enum member_status: [:active, :deactivated]
    enum subscription_status: [:paid, :unpaid]

    scope :having_sub_date_between, ->(start_date, end_date) { where(subscribe_date: start_date..end_date) }

end
