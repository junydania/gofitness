class ResetCheckInStatusJob < ApplicationJob
  queue_as :reset_check_in

  def perform 
    Member.joins(:account_detail).where(account_details: {gym_attendance_status: 1}).find_each do |member|
      if !member.attendance_records.nil?
        checked_in_date = member.attendance_records.last.checkin_date
        if DateTime.now > checked_in_date
          member.account_detail.gym_attendance_status = 0
          member.save
        end
      end
    end
  end

  
end
