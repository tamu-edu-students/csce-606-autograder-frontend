  Background:
    Given the following assignments exist:
      | assignment_name | repository_name |
      | assignment1     | assignment1     |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"

  Scenario: Required fields should be marked with asterisks
    Then I should see an asterisk next to the "name" field
    And I should see an asterisk next to the "points" field
    And I should see an asterisk next to the "target" field
    And I should see an asterisk next to the "type" field

  @javascript
  Scenario Outline: "Create Test" becomes active when all required fields are filled
    When I enter "<name>" in the name field
    And I enter "<points>" in the points field
    And I select "<type>" as the test type
    And I enter "<target>" in the target field
    Then the "Create Test" button should be active

    Examples: All fields are required
      | name      | points | type          | target             |
      | Test1    | 5.0    | unit          | tests/unit_test.js |
      | Test2    | 2.5    | i_o           | tests/input.txt    |

    Examples: Target field not required for specific types
      | name      | points | type           | target |
      | Compile_T | 3.0    | compile        |        |
      | Memory_T  | 1.0    | memory_errors  |        |
      | Script_T  | 4.0    | script         |        |

  @javascript
  Scenario Outline: Create Test button remains disabled until only some required fields are filled
    When I fill in the following fields with values:
      | field   | value         |
      <filled_fields>

    Then the "Create Test" button should remain disabled

    Examples: Only some fields filled
        | filled_fields                                     | blank_fields           |
        | name: Sample Test                                 | points, target, type   |
        | points: 10.5                                      | name, target, type     |
        | target: main.cpp                                  | name, points, type     |
        | type: unit                                        | name, points, target   |
        | name: Sample Test, points: 10.5                   | target, type           |
        | name: Sample Test, target: main.cpp               | points, type           |
        | points: 10.5, type: unit                          | name, target           |
        | target: main.cpp, type: unit                      | name, points           |
        | points: 10.5, target: main.cpp, type: unit        | name                   |
        | name: Sample Test, target: main.cpp, type: unit   | points                 |
        | name: Sample Test, points: 10.5, type: unit       | target                 |
        | name: Sample Test, points: 10.5, target: main.cpp | type                   |


  @javascript
  Scenario: Create Test button becomes enabled when all required fields are filled
    When I fill in "name" with "Sample Test"
    And I fill in "points" with "10.5"
    And I fill in "target" with "main.cpp"
    And I fill in "type" with "unit_test"
    Then the "Create Test" button should be enabled

  @javascript
  Scenario: Create Test button becomes disabled when a required field is cleared
    When I fill in "name" with "Sample Test"
    And I fill in "points" with "10.5"
    And I fill in "target" with "main.cpp"
    And I fill in "type" with "unit_test"
    And I clear the "name" field
    Then the "Create Test" button should be disabled
  
