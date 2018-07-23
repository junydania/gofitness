class AddPauseActualCancelDateToPauseHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :pause_histories, :pause_actual_cancel_date, :datetime
  end
end
