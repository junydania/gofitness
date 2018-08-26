class Loyalty < ApplicationRecord

    audited associated_with: :member
    
    enum loyalty_type: [:register, :renewal, :referal]
    validates_presence_of   :loyalty_type, :loyalty_points_percentage

end

