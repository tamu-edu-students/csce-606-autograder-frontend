Feature: Log in to the application
  As a CSCE 120 GitHub Organization member
  So that I can create, modify, and view autograded assignments
  I want to authenticate with a third-party service and login to the system

  Background: Users in the GitHub organization
    Given the following users are in the GitHub organization:
      | name     | email              | role        |
      | alice    | alice@example.com  | instructor  |
      | bob      | bob@example.com    | ta          |
      | dave     | dave@example.com   |             | 
    And I am on the "Login" page

  Scenario: Instructor logs in with valid credentials
    When I log in with GitHub as "alice"
    Then I should see the "Course Dashboard" page
    And I should have the role "instructor"

  Scenario: TA logs in with valid credentials
    When I log in with GitHub as "bob"
    Then I should see the "Course Dashboard" page
    And I should have the role "ta"

  Scenario: Non-organization user logs in with valid credentials
    When I log in with GitHub as "dave"
    Then I should see the "Login" page
    And I should see the error message "You must be a member of CSCE-120 organization to access this application."

  Scenario: User logs in with invalid credentials
    When I attempt to log in with GitHub with invalid credentials
    Then I should see the "Login" page
    And I should see the error message "GitHub authentication failed. Please try again."