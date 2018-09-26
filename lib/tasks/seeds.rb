user = User.create!(
    [{
         email: 'dominic@gofitnessng.com',
         password: 'dominic',
         password_confirmation: 'dominic',
         first_name: 'Dominic',
         last_name: 'Mudabai',
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