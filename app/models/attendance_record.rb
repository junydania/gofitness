class AttendanceRecord < ApplicationRecord
    
    audited associated_with: :member

    enum membership_status: [:active, :deactivated, :paused]
    
    belongs_to :member

    
end

