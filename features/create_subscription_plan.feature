Feature: As an administrator
  In order to know all users in the system
  I should see a table with all users name


  Background:
    Given the following user account exist
      | email                  | first_name  | last_name | password | password_confirmation | role           |
      | o.dania@aol.com        | Osegbemoh   | Dania     | 12345678 | 12345678              | manager        |

   
   Given the following features exist
      | name             | description              | 
      | Diet Plan        |Free weight loss plan     |
      | Coach            |Coach Led                 |
    

  Scenario:
    Given I visit the "sign_in" page
    And I fill in field "login_user_email" with "o.dania@aol.com"
    And I fill in field "user_password" with "12345678"
    And I click on "Log In"
    And I click on "Subscription Plan"
    And I click on "Create Plan"
    And I fill in field "Plan Name" with "Basic"
    And I fill in field "Cost" with "15000"
    And I fill in field "subscription_plan_description" with "Gofitness Basic monthly package"
    And I select "Monthly" from "Duration"
    And I select "No" from "group_plan_select"
    And I select "Diet Plan" from "subscription_plan_feature_ids"
    And I click on "Create"
    Then I should see "New Plan Successfully Created"

