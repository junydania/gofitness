FactoryBot.define do
  factory :general_transaction do
    member_fullname "MyString"
    transaction_type 1
    subscribe_date "2018-06-28 00:11:33"
    expiry_date "2018-06-28 00:11:33"
    staff_responsible "MyString"
    payment_method 1
    loyalty_earned 1
    loyalty_redeemed 1
    membership_plan "MyString"
    membership_status 1
    customer_code ""
    member_email "MyString"
    loyalty_type 1
    amount 1
  end
end
