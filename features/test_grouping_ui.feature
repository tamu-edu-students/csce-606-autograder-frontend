Feature: Improving Test Groups UI for better usability.
  As a CSCE 120 GitHub organization member
  So that I can interact with test case groupings
  I want to see better UI for test groups

  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment1       | main.cpp\nhelper.cpp\nhelper.h\n |
        | assignment2     | assignment2       | main.cpp\nhelper.cpp\nhelper.h\n |
        | assignment3     | assignment3       | main.cpp\nhelper.cpp\nhelper.h\n |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    And the following test case groupings exist for "assignment1":
        | grouping_name       |
        | Basic Functionality |
        | Edge Cases          |
    And "<Test Name>" test exists in "<Grouping Name>" in order
        |Test Name              | Grouping Name       |
        |Test_BF_1              | Basic Functionality |
        |Test_BF_2              | Basic Functionality |
        |Test_EC_1              | Edge Cases          |
        |Test_EC_2              | Edge Cases          |

  Scenario Outline: Verify the UI updates for test groups
    Then I should not be able to update grouping name in the test group
    And I should see a point editor next to each test
    And I should see a point total field at top
