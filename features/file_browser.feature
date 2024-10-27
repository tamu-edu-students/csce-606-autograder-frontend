Feature: File browser 
  As a CSCE 120 GitHub organization member
  So that I can see the File Directory of selected assignment
  I want to be able to see the file browser

  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment1       |
        | assignment2     | assignment2       |
        | assignment3     | assignment3       |
    
    
  Scenario: File tree directory is present for the selected assignment
    Given I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    Then I should see the file directory of "assignment1"
    And I should see a directory dropdown displayed