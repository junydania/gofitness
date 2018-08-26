class PosTransaction < ApplicationRecord

    audited
    
    belongs_to :member
    
end
