Feature: File Selection 
  As a CSCE 120 organization member
  So that I can select the files for a test
  I want to see a dropdown of nested files with a checkbox


  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment1       |
        | assignment2     | assignment2       |
        | assignment3     | assignment3       |
    
    
  Scenario: File tree directory is present for the selected assignment
    Given I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    Then I should see the file selection partial for a test
    And I should be able to select multiple files
    And I should see the selected files as an array in the target field
