class HealthCondition < ApplicationRecord
    has_many :member_health_conditions
    has_many :members, through: :member_health_conditions
end

