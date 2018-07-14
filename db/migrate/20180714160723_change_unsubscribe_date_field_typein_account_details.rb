class ChangeUnsubscribeDateFieldTypeinAccountDetails < ActiveRecord::Migration[5.1]
  
  def change
    remove_column :account_details, :unsubscribe_date, :integer
    add_column :account_details, :unsubscribe_date, :datetime
  end

end
