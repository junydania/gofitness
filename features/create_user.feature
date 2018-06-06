Feature: As an administrator
  In order to know all users in the system
  I should see a table with all users name


  Background:
    Given the following user account exist
      | email                  | first_name  | last_name | password | password_confirmation | role           |
      | o.dania@aol.com        | Osegbemoh   | Dania     | 12345678 | 12345678              | manager        |
      | o.dania@icloud.com     | Ose         | Dee       | 12345678 | 12345678              | supervisor     |
      | o.dania@efluxz.com     | Friday      | David     | 12345678 | 12345678              | supervisor     |
      | junydania@gmail.com    | Toby        | Dania     | 12345678 | 12345678              | manager        |


  Scenario:
    Given I visit the "sign_in" page
    And I fill in field "login_user_email" with "o.dania@aol.com"
    And I fill in field "user_password" with "12345678"
    And I click on "Log In"
    And I should see "GoFitness Dashboard"
    And I click on "Staff"
    And I click on "Create Staff"
    And I fill in field "user_email" with "juniordania@hotmail.com"
    And I fill in field "user_password" with "12345678"
    And I fill in field "user_password_confirmation" with "12345678"
    And I fill in field "user_first_name" with "Tobias"
    And I fill in field "user_last_name" with "Dania"
    And I select "Supervisor" from "user_role"
    And I click on "Create"
    Then I should see "User successfully created"
    