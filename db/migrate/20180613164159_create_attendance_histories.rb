class CreateAttendanceHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_histories do |t|
      t.datetime :checkin_datetime
      t.string :status_checking_in

      t.timestamps
    end
  end
end
