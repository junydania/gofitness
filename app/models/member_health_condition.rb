class MemberHealthCondition < ApplicationRecord
    belongs_to :member
    belongs_to :health_condition

end


