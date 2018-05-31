Feature: As an administrator
  In order to have users add content into the catalogue
  I should be able to create new users in the system


  Background:
    Given the following user account exist
      | email                | first_name  | last_name | password | password_confirmation | role           |
      | o.dania@aol.com      | Osegbemoh   | Dania     | 12345678 | 12345678              | manager        |


  Scenario:
    Given I visit the "sign_in" page
    And I fill in field "login_user_email" with "o.dania@aol.com"
    And I fill in field "user_password" with "12345678"
    And I click on "Log In"
    And I should see "GoFitness Dashboard"
    And I click on "Staff"
    And I click on "Create Staff"
    And I fill in field "Email" with "juniordania@hotmail.com"
    And I fill in field "Password" with "12345678"
    And I fill in field "Password Confirmation" with "12345678"
    And I fill in field "First Name" with "Tobias"
    And I fill in field "Last Name" with "Dania"
    And I select "Supervisor" from "Role"
    And I click on "Create"
    Then I should see "User successfully created"

