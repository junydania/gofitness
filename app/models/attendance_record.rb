class AttendanceRecord < ApplicationRecord
    
    audited associated_with: :member
    
    belongs_to :member
    
end

