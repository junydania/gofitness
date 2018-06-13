Feature: As an administrator
  In order to assign a method to a customer
  I should be able to create a new payment method


  Background:
    Given the following user account exist
      | email                  | first_name  | last_name | password | password_confirmation | role           |
      | o.dania@aol.com        | Osegbemoh   | Dania     | 12345678 | 12345678              | manager        |

   
  Scenario:
    Given I visit the "sign_in" page
    And I fill in field "login_user_email" with "o.dania@aol.com"
    And I fill in field "user_password" with "12345678"
    And I click on "Log In"
    And I click on "Payment Method"
    And I click on "View/Create Payment Method"
    And I fill in field "Payment System" with "Cash"
    And I fill in field "Discount" with "10"
    And I click on "Create"
    Then I should see "New Payment Successfully Created"

    
