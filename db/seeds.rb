# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.create!(
    [{
         email: 'dominic@gofitnessng.com',
         password: 'dominic',
         password_confirmation: 'dominic',
         first_name: 'Ose',
         last_name: 'Dan',
         role: 0
     }, {
         email: 'o.dania@icloud.com',
         password: 'osegbemoh',
         password_confirmation: 'osegbemoh',
         first_name: 'Osegbemoh',
         last_name: 'Dania',
         role: 0
     }]
)

Plutus::Asset.create(:name => "Accounts Receivable")
Plutus::Asset.create(:name => "Cash")
Plutus::Asset.create(:name => "Card Payment")
Plutus::Revenue.create(:name => "Sales Revenue")
Plutus::Liability.create(:name => "Unearned Revenue")
Plutus::Liability.create(:name => "Sales Tax Payable")
