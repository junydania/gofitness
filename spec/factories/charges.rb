FactoryBot.define do
  factory :charge do
    service_plan "MyString"
    amount 1
    payment_method "MyString"
    duration "MyString"
    gofit_transaction_id "MyString"
    member nil
    subscribe_date "2018-08-28 00:05:46"
    expiry_date "2018-08-28 00:05:46"
  end
end
