class Member < ApplicationRecord
    has_many :member_health_conditions
    has_many :health_conditions, through: :member_health_conditions
    belongs_to :fitness_goal
    belongs_to :payment_method
    belongs_to :subscription_plan

    validates_presence_of :customer_code, :first_name, :last_name, :email, :phone_number, :next_of_kin_name, 
                           :next_of_kin_phone, :next_of_kin_email, :date_of_birth
end

