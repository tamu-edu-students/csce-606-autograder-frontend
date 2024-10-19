Feature: Navigation Bar
  As an instructor (or TA)
  So that I can easily navigate to different pages of the app (course dashboard, logout, manage users, app name)
  I want to have a navigation bar at the top of the view that lets me browse quickly to the other pages of the application

  Background:
   Given I am logged in as an "organization member"

  Scenario: Display navigation bar with links
    When I am on any page of the app
    Then I should see a navigation bar at the top of the view
    And the navigation bar should have the following links:
      | Link Text           | Link Target      |
      | Course Dashboard    | /assignments     |
      | Manage Users        | /users           |
      | Logout              | /logout          |
      | Autograder Frontend | /assignments     |

  Scenario: Navigate to Course Dashboard
    When I am on any page of the app
    When I click the "Course Dashboard" link in the navigation bar
    Then I should be redirected to the "course dashboard" page at "/assignments"
    And I should see the "Assignments" page

  Scenario: Navigate to Manage Users
    When I am on any page of the app
    When I click the "Manage Users" link in the navigation bar
    Then I should be redirected to the "manage users" page at "/users"
    And I should see the "Manage Users" page

  Scenario: Navigate to App Home via App Name
    When I am on any page of the app
    When I click the app name in the navigation bar
    Then I should be redirected to the "home" page at "/assignments"
    And I should see the "Assignments" page

  Scenario: Logout via navigation bar
    When I am on any page of the app
    When I click the "Logout" link in the navigation bar
    Then I should be redirected to the "login" page
    And I should be logged out of the system

  Scenario: Navigation bar persists across pages
    Given I am on the "Course Dashboard" page
    When I click the "Manage Users" link in the navigation bar
    Then I should still see the navigation bar at the top of the page