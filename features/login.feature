Feature: Log in to the
  As a CSCE 120 GitHub Organization member
  So that I can create, modify, and view autograded assignments
  I want to authenticate with a third-party service and login to the system

  Background: Users in the GitHub organization
    Given the following users are in the GitHub organization:
      | username | password | role          |
      | alice    | password | instructor    |
      | bob      | password | ta-read-only  |
      | charlie  | password | ta-read-write |
      | dave     | password |               |

  Scenario: Instructor logs in with valid credentials
    Given I am on the login page
    When I fill in "username" with "alice"
    And I fill in "password" with "password"
    And I press "Log in"
    Then I should see the course dashboard page
    And I should have the role "instructor"

  Scenario: TA with write privileges logs in with valid credentials
    Given I am on the login page
    When I fill in "username" with "bob"
    And I fill in "password" with "password"
    And I press "Log in"
    Then I should see the course dashboard page
    And I should have the role "manager"

  Scenario: TA with read-only privileges logs in with valid credentials
    Given I am on the login page
    When I fill in "username" with "charlie"
    And I fill in "password" with "password"
    And I press "Log in"
    Then I should see the course dashboard page
    And I should have the role "ta-read-write"

  Scenario: Non-organization user logs in with valid credentials
    Given I am on the login page
    When I fill in "username" with "dave"
    And I fill in "password" with "password"
    And I press "Log in"
    Then I should see the login page
    And I should see the error message "Invalid username or password"

  Scenario: User logs in with invalid credentials
    Given I am on the login page
    When I fill in "username" with "alice"
    And I fill in "password" with "wrongpassword"
    And I press "Log in"
    Then I should see the login page
    And I should see the error message "Invalid username or password"