Feature: Approved Files UI
  As a CSCE 120 GitHub organization member
  So that I can input approved files when creating an assignment and invoke them in tests
  I want the necessary user interfaces to do so

  Background: Assignments in the GitHub organization
    Given I am logged in as an "instructor" named "alice"

  Scenario: Adding approved files during assignment creation
    When I click the "Create Assignment" button
    Then I should see the "Approved files" text area
    When I fill in "Assignment name" with "assignment-1"
    And I fill in "Repository name" with "assignment-1"
    And I add "main.cpp\nhelper.cpp\nhelper.h\n" to the "Approved files" field
    And I click the "Submit" button
    Then I should see a success message "Assignment was successfully created."

  Scenario: Approved files are available in the target field dropdown
    Given an assignment with name "assignment-1", repository name "assignment-1", and approved files "main.cpp\nhelper.cpp\nhelper.h\n"
    And I am on the "Assignment Management" page for "assignment-1"
    Then the "Target" dropdown should contain the following options:
      | Select a target file    |
      | main.cpp                |
      | helper.cpp              |
      | helper.h                |