class AttendanceRecord < ApplicationRecord
    
    audited
    
    belongs_to :member
    
end

