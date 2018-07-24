class CreateAttendanceRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_records do |t|
      t.datetime :checkin_date
      t.datetime :checkout_date
      t.integer :membership_status
      t.string :membership_plan
      t.string :staff_on_duty

      t.timestamps
    end
  end
end
