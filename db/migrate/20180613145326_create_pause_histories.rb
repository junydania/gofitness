class CreatePauseHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :pause_histories do |t|
      t.datetime :pause_start_date
      t.string :pause_reason
      t.datetime :pause_cancel_date

      t.timestamps
    end
  end
end
