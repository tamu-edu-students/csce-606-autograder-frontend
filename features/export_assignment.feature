Feature: Export assignment
  As an instructor or TA with read access to an assignment
  So that I can upload an autograder assignment to Gradescope
  I want to download the autograder assignment as a .zip file

  Scenario: Export an assignment as an organization member
    Given I am logged in as an "organization member"
    Given I am on the "Assignment Management" page for "csce-120-hw1"
    When I click the "Create and Download ZIP" button for "csce-120-hw1"
    Then I should see "csce-120-hw1.zip" file in my downloads folder
