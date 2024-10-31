Feature: File Upload 
  As a CSCE 120 GitHub organization member
  So that I can upload new test files
  I want to be able to see the new file in the file tree directory

  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment1       |
        | assignment2     | assignment2       |
        | assignment3     | assignment3       |
    

  Scenario: Upload a new test file using "Upload file" button
    Given I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    When I select the "target" folder in file tree 
    And I upload a new file "temp_test.c" using "Upload File" button
    Then I should see the "temp_test.c" file under the "target" folder in file directory
    And I should see a message "File is successfully uploaded."