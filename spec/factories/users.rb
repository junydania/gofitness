FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name "OJ"
    last_name "Dania"
    password "12345678"
    password_confirmation "12345678"
    role { User.roles.keys.sample }

    factory :manager do
      after(:create) {|user| user.role = 'manager'}
    end

    factory :supervisor do
      after(:create) {|user| user.role = 'supervisor'}
    end

    factory :officer do
      after(:create) {|user| user.role = 'officer'}

    end

    factory :guest do
      after(:create) {|user| user.role = 'guest'}
    end

  end
end
