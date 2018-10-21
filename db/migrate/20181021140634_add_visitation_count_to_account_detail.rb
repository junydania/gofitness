class AddVisitationCountToAccountDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :account_details, :visitation_count, :integer, default: 0
  end
end
