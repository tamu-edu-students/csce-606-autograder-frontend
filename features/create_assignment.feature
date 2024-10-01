Feature: Create a new assignment
  As an instructor for CSCE 120
  So that I can create autograded assignments for my students
  I want to create a new Git repository under the CSCE 120 GitHub
  organization from the autograded-assignment-template repository

  Scenario: Create a new assignment as an instructor or ta-read-write
    Given I am logged in as an "instructor"
    When I click the "Create Assignment" button
    And I fill in the repository name with "csce-120-hw1"
    And I fill in the description with "Homework 1"
    And I click the "Create" button
    Then I should see the new assignment in the course assignments list
    And I should see the "csce-120-hw1" repository in the CSCE 120 GitHub organization
    And I should see a local clone of the "csce-120-hw1" repository
    And I should see the "autograder_core_deploy_key" in "/secrets" of the "csce-120-hw1" repository
    And I should see the deploy_key in "/secrets" of the "csce-120-hw1" repository

  Scenario: Duplicate repository names should not be allowed
    Given An assignment with the name "csce-120-hw1"
    When I try to create an assignment with the name "csce-120-hw1"
    Then I should see an error message

  Scenario: TAs with read-only access should not see the "Create Assignment" button
    Given I am logged in as a "ta-read-write"
    Then I should not see the "Create Assignment" button

  Scenario: TAs with read-only access cannot visit the "Create Assignment" page
    Given I am logged in as a "ta-read-only"
    When I try to visit the "Create Assignment" page
    Then I should see an error message



