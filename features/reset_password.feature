Feature: As a user or administrator
  In order to change my password
  I should be able to reset my password from the login page


  Background:
    Given the following user account exist
      | email                | first_name  | last_name | password | password_confirmation | role           |
      | o.dania@icloud.com   | Osegbemoh   | Dania     | 12345678 | 12345678              | manager        |

  Scenario: Change password for existing user
    Given I visit the "sign_in" landing page
    And I click on "Forgot pwd?"
    And I fill in field "Email" with "o.dania@icloud.com"
    And I click on "Reset"
    And I should receive a "Reset password instructions" email
    When I click on the retrieve password link in the last email
    Then I should see "Change Your Password"
    And I fill in "New Password" with "12345678"
    And I fill in "Confirm Password" with "12345678"
    And I click on "Change Password"
    # And I should see "Your password has been changed successfully. You are now signed in."


