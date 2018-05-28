Feature: As Gym administrator
  In order to manage authentication & security of the app
  Users must login to the application


  Background:
    Given the following user account exist
      | email               | first_name  | last_name | password | password_confirmation   | role           |
      | o.dania@aol.com     | Osegbemoh   | Dania     | 12345678  | 12345678               | manager        |

  Scenario:
    Given I visit the "sign_in" landing page
    And I fill in field "login_user_email" with "o.dania@aol.com"
    And I fill in field "user_password" with "12345678"
    And I click on "Log In"
    And I should see "Signed in successfully."

