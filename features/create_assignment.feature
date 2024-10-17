Feature: Create a new assignment
  As an instructor for CSCE 120
  So that I can create autograded assignments for my students
  I want to create a new Git repository under the CSCE 120 GitHub
  organization from the autograded-assignment-template repository

  Scenario: Create a new assignment as an instructor
    Given I am logged in as an "instructor" named "alice"
    When I click the "Create Assignment" button
    And I fill in "Assignment Name" with "Homework 1"
    And I fill in "Repository Name" with "csce-120-hw1"
    And I click the "Submit" button
    Then I should see the "Homework 1" assignment
    And I should see a local clone of the "csce-120-hw1" repository
    And I should see "deploy_key" in "assignment-repos/csce-120-hw1/secrets"
    And I should see "autograder_core_deploy_key" in "assignment-repos/csce-120-hw1/secrets"

  Scenario: Duplicate repository names should not be allowed
    Given I create an assignment with the name "Homework 1" and the repository "csce-120-hw1"
    When I create an assignment with the name "Homework 1" and the repository "csce-120-hw1"
    Then I should see the error message "must be unique. This repository name is already taken."

  Scenario: TAs with read-only access should not see the "Create Assignment" button
    Given I am logged in as a "ta"
    Then I should not see the "Create Assignment" button



