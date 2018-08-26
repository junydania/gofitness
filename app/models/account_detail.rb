class AccountDetail < ApplicationRecord
    
    audited
    
    belongs_to :member
    enum member_status: [:active, :deactivated, :paused]
    enum gym_attendance_status: [:checkedout, :checkedin]

end
