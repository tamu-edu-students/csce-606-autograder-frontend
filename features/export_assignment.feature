Feature: Export assignment
  As an instructor or TA with read access to an assignment
  So that I can upload an autograder assignment to Gradescope
  I want to download the autograder assignment as a .zip file

  Scenario: Export an assignment as an organization member
    Given I am logged in as an "organization member"
    Given the following assignments exist:
        | assignment_name | repository_name | files_to_submit                  |
        | csce-120-hw1    | csce-120-hw1    | main.cpp\nhelper.cpp\nhelper.h\n |
    Given I am on the "Assignment Management" page for "csce-120-hw1"
    When I click the "Export to Gradescope" button for "csce-120-hw1"
    Then I should see "csce-120-hw1.zip" file in my downloads folder
