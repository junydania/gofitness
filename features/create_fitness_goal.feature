Feature: As an administrator
  In order to set fitness goals in the system
  I should be able to create new fitness goal


  Background:
    Given the following user account exist
      | email                  | first_name  | last_name | password | password_confirmation | role           |
      | o.dania@aol.com        | Osegbemoh   | Dania     | 12345678 | 12345678              | manager        |

   
  Scenario:
    Given I visit the "sign_in" page
    And I fill in field "login_user_email" with "o.dania@aol.com"
    And I fill in field "user_password" with "12345678"
    And I click on "Log In"
    And I click on "Fitness Goal"
    And I click on "View/Create Goal"
    And I fill in field "Goal Name" with "Weight Loss"
    And I click on "Create"
    Then I should see "New Goal Successfully Created"

    
