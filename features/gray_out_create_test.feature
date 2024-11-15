  Feature: "Create Test" should be grayed out until minimum necessary information is entered
    As a CSCE 120 GitHub organization member
    So that I do not see the create button active while creating a test
  
  Background:
    Given the following assignments exist:
      | assignment_name | repository_name | files_to_submit                        |
      | assignment1     | assignment1     | tests/unit_test.js \n tests/input.txt \n main.cpp  |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"

  Scenario: Required fields should be marked with asterisks
    Then I should see an asterisk next to the "name" field
    And I should see an asterisk next to the "points" field
    And I should see an asterisk next to the "type" field
    And I should see an asterisk next to the "target" field
    

  @javascript
  Scenario Outline: "Create Test" becomes active when all required fields are filled
    When I create a new test with type "<type>"
    And with the name "<name>"
    And with the points "<points>"
    And with the target "<target>"
    Then I should see the asterisk on target field based on test type "<type>"
    And the "Create Test" button should be active
    
    Examples: All fields are required
      | name      | points | type         | target      |
      | Test1    | 5.0    | unit          | main.cpp    |
      | Test2    | 2.5    | i_o           | main.cpp    |

    Examples: Target field not required for specific types
      | name      | points | type           | target                     |
      | Compile_T | 3.0    | compile        | Select a target file       |
      | Memory_T  | 1.0    | memory_errors  |  Select a target file      |
      | Script_T  | 4.0    | script         | Select a target file       |



 @javascript
Scenario: Create Test button remains disabled until only some required fields are filled
  When I create a new test with type "<type>"
  And with the name "<name>"
  And with the points "<points>"
  And with the target "<target>"
  Then the "Create Test" button should remain disabled
  Examples: 
    | name        | points | type                          | target   |
    | Sample Test |        | Please select a test type     |          |
    |             | 10.5   | Please select a test type     |          |
    |             |        | unit                          |          |
    |             |        | Please select a test type     | main.cpp |
    | Sample Test | 10.5   | Please select a test type     |          |
    | Sample Test |        | Please select a test type     | main.cpp |
    |             | 10.5   | unit                          |          |
    |             |        | unit                          | main.cpp |
    |             | 10.5   | unit                          | main.cpp |
    | Sample Test |        | unit                          | main.cpp |
    | Sample Test | 10.5   | unit                          |          |
    | Sample Test | 10.5   | Please select a test type     | main.cpp |



  @javascript
  Scenario: Create Test button becomes enabled when all required fields are filled
    When I create a new test with type "<type>"
    And with the name "<name>"
    And with the points "<points>"
    And with the target "<target>"
    Then the "Create Test" button should be active
    Examples:
      | name     | points | type          | target             |
      | Test1    | 5.0    | unit          | main.cpp           |
      | Test2    | 2.5    | i_o           | main.cpp           |

  @javascript
  Scenario: Create Test button becomes disabled when a required field is cleared
    When I create a new test with type "<type>"
    And with the name "<name>"
    And with the points "<points>"
    And with the target "<target>"
    And I clear the "name" field
    Then the "Create Test" button should remain disabled
    Examples:
      | name     | points | type          | target             |
      | Test1    | 5.0    | unit          | tests/unit_test.js |
      | Test2    | 2.5    | i_o           | tests/input.txt    |
  