class OneOffRevenue < ApplicationRecord

    enum cost_type: [:register, :renewal, :deactivation]
    validates_presence_of   :cost_type, :amount


end
