# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.create!(
    [{
         email: 'odania@gofitness.com',
         password: '12345678',
         password_confirmation: '12345678',
         first_name: 'Ose',
         last_name: 'Dan',
         role: 0
     }, {
         email: 'o.dania@icloud.com',
         password: '12345678',
         password_confirmation: '12345678',
         first_name: 'Osegbemoh',
         last_name: 'Dania',
         role: 1
     }]
)


Plutus::Asset.create(:name => "Accounts Receivable")
Plutus::Asset.create(:name => "Cash")
Plutus::Asset.create(:name => "Card Payment")
Plutus::Revenue.create(:name => "Sales Revenue")
Plutus::Liability.create(:name => "Unearned Revenue")
Plutus::Liability.create(:name => "Sales Tax Payable")