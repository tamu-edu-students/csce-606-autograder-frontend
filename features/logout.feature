Feature: Logout System
  As an instructor (or TA)
  So that I can ensure my session is closed and my work is protected when I have completed my tasks
  I want to securely log out of the system

  Background:
    Given I am on the "Login" page

  Scenario: Successful logout
    When I log in with GitHub as "alice" who has the role of "instructor"
    And I click the "Logout" link in the navigation bar
    Then I should be logged out of the system
    And I should be redirected to the "login" page
    And I should see a message saying "Logged out successfully"

  Scenario: Ensure session is invalidated after logout
    When I log in with GitHub as "alice" who has the role of "instructor"
    And I click the "Logout" link in the navigation bar
    And I try to access a protected page 
    Then I should be redirected to the "login" page
    Then I should see a message saying "Please log in to access this page"

  Scenario: Logout button is visible
    When I log in with GitHub as "alice" who has the role of "instructor"
    And I am on any page of the app
    Then I should see a "Logout" button in the navigation bar

  
  Scenario: Logout button is not visible
    When I log in with GitHub as "alice" who has the role of "instructor"
    And I am on any page of the app
    And I click the "Logout" link in the navigation bar
    Then I should be redirected to the "login" page
    And I should not see a "Logout" button in the navigation bar
  