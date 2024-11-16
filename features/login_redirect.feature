  Feature: Login Page Changes
    As a CSCE 120 GitHub organization member
    So that I can have ease of use
    I want to be automatically be taken past the login page if I am already logged in

  Scenario: Already logged-in user visits login page
    Given I am logged in as an "instructor"
    When I navigate to the home page
    Then I should be automatically redirected to the course dashboard

  Scenario: Not logged-in user visits login page
    Given I am not logged in to the system
    When I navigate to the login page
    Then I should not be redirected

  Scenario: Not logged-in user visits course dashboard
    Given I am not logged in to the system
    When I attempt to access the course dashboard
    Then I should be redirected to the login page