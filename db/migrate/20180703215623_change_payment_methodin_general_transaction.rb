class ChangePaymentMethodinGeneralTransaction < ActiveRecord::Migration[5.1]
  def change
    remove_column :general_transactions, :payment_method, :integer
    add_column :general_transactions, :payment_method, :string
  end
end
