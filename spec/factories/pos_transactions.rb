FactoryBot.define do
  factory :pos_transaction do
    transaction_success false
    transaction_reference "MyString"
    processed_by "MyString"
  end
end
