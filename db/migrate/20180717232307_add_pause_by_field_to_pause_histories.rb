class AddPauseByFieldToPauseHistories < ActiveRecord::Migration[5.1]
  def change
    remove_column :pause_histories, :pause_reason, :integer
    add_column :pause_histories, :paused_by, :string
  end
end
