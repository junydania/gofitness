class Loyalty < ApplicationRecord

    enum loyalty_type: [:register, :renewal, :referal]
    validates_presence_of   :loyalty_type, :loyalty_points_percentage

end

