class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.integer :customer_code
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :phone_number
      t.string :next_of_kin_name
      t.integer :next_of_kin_phone
      t.string :next_of_kin_email
      t.string :address
      t.date :date_of_birth
      t.string :referal_name
      t.string :voucher_code
      t.timestamps
    end
  end
end
