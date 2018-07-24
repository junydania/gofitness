class AddMemberToAttendanceRecord < ActiveRecord::Migration[5.1]
  def change
    add_reference :attendance_records, :member, index: true
  end
end
