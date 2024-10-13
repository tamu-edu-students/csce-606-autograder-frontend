Feature: Logout System
  As an instructor (or TA)
  So that I can ensure my session is closed and my work is protected when I have completed my tasks
  I want to securely log out of the system

  Background:
    Given I am logged in as an instructor or TA

  Scenario: Successful logout
    When I click the "Logout" button
    Then I should be logged out of the system
    And I should be redirected to the login page
    And I should see a message "You have successfully logged out"

  Scenario: Ensure session is invalidated after logout
    When I click the "Logout" button
    And I try to access a protected page 
    Then I should be redirected to the login page
    And I should see a message "Please log in to access this page"

  Scenario: Logout button is visible
    When I am on any page within the system
    Then I should see a "Logout" button in the navigation bar

  Scenario: Logout button is not visible
    When I click the "Logout" button
    Then I should be redirected to the login page
    And I should not see a "Logout" button in the navigation bar