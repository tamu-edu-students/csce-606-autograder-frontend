Feature: Create a new test case
    As an instructor or TA with write access to an assignment
    So that I can test some functionality of student code
    I want to add a new test case to an assignment

    Background: Assignments in the GitHub organization
        Given the following assignments exist:
            | assignment_name | repository_name   | files_to_submit                  |
            | assignment1     | assignment1       | main.cpp\nhelper.cpp\nhelper.h\n |
            | assignment2     | assignment2       | main.cpp\nhelper.cpp\nhelper.h\n |
            | assignment3     | assignment3       | main.cpp\nhelper.cpp\nhelper.h\n |
        Given I am logged in as an "instructor"
        And I am on the "Assignment Management" page for "assignment1"

    Scenario: Tests with unknown type
        When I create a new test with type "invalid"
        Then I should see an error message saying "Unknown test type: invalid"

    @javascript
    Scenario: Test has required attributes
        When I create a new test with type "<type>"
        And with the name "<name>"
        And with the points "<points>"
        And with the target "<target>"
        Then I should see the "<type>" dynamic test block partial
        And I add the "<type>" dynamic text block field
        And I click the "Create Test" button
        And I should see a message saying "Test was successfully created"
        Then I should not see any missing attribute error messages

        Examples:
        | type              | name  | points | target      |
        | approved_includes | test1 | 10     | main.cpp    |
        | compile           | test2 | 10     | helper.cpp  |
        | memory_errors     | test3 | 10     | helper.h    |
        | coverage          | test4 | 10     | main.cpp    |
        | unit              | test5 | 10     | helper.cpp  |
        | i_o               | test6 | 10     | helper.h    |
        | performance       | test7 | 10     | main.cpp    |
        | script            | test8 | 10     | helper.cpp  |

    @javascript
    Scenario: Exempt tests missing target
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      Then I should see the "<type>" dynamic test block partial
      And I add the "<type>" dynamic text block field
      And I click the "Create Test" button
      And I should see a message saying "Test was successfully created"
      Then I should not see any missing attribute error messages

      Examples:
        | type          | name  | points | target |
        | compile       | test1 | 10     |        |
        | memory_errors | test2 | 10     |        |
        | script        | test3 | 10     |        |

    @javascript
    Scenario: Non-exempt tests missing target
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      Then I should see the "<type>" dynamic test block partial
      And I add the "<type>" dynamic text block field
      Then the "Create Test" button should remain disabled

      Examples:
        | type              | name  | points | target |
        | approved_includes | test1 | 10     |        |
        | coverage          | test2 | 10     |        |
        | unit              | test3 | 10     |        |
        | i_o               | test4 | 10     |        |
        | performance       | test5 | 10     |        |

    @javascript
    Scenario: Tests missing one of [name, points, type]
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And with the target "<target>"
      Then I should see the "<type>" dynamic test block partial
      And I add the "<type>" dynamic text block field
      Then the "Create Test" button should remain disabled

      Examples:
        | type              | name  | points | target      | attribute |
        | memory_errors     |       | 10     | main.cpp    | name      |
        | script            | test3 |        | helper.cpp  | points    |
        | approved_includes |       | 10     | helper.h    | name      |
        | coverage          | test2 |        | main.cpp | points    |

    @javascript
    Scenario Outline: Tests missing multiple required attributes
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And with the target "<target>"
      Then I should see the "<type>" dynamic test block partial
      And I add the "<type>" dynamic text block field
      Then the "Create Test" button should remain disabled

      Examples:
        | type              | name  | points | target      | attribute1 | attribute2 |
        | memory_errors     |       |        | main.cpp    | name       | points     |
        | unit              | test3 |        |             | points     | target     |
        | approved_includes |       |        | helper.cpp  | name       | points     |
        | coverage          |       | 10     |             | name       | target     |


  Rule: Test names must be unique
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    @javascript
    Scenario: Test names are unique
      When I create a new test with type "unit"
      And with the name "test0"
      And with the points "10"
      And with the target "main.cpp"
      Then I should see the "unit" dynamic test block partial
      And I add the "unit" dynamic text block field
      And I click the "Create Test" button
      Then I should not see an error message saying "Test name must be unique"

    @javascript
    Scenario: Test names are not unique
      When I create a new test with type "unit"
      And with the name "test1"
      And with the points "10"
      And with the target "main.cpp"
      Then I should see the "unit" dynamic test block partial
      And I add the "unit" dynamic text block field
      And I click the "Create Test" button

      When I create a new test with type "unit"
      And with the name "test1"
      And with the points "10"
      And with the target "main.cpp"
      Then I should see the "unit" dynamic test block partial
      And I add the "unit" dynamic text block field
      And I click the "Create Test" button
      Then I should see an error message saying "Test name must be unique"

  Rule: Test blocks must prompt user for correct fields
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n     |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    @javascript
    Scenario Outline: Test block contains correct fields
      When I create a new test with type "<type>"
      And with the name "test1"
      And with the points "10"
      And with the target "main.cpp"
      Then I should see the "<type>" dynamic test block partial
      And I add the "<type>" dynamic text block field
      And I click the "Create Test" button
      Then the test block should contain the fields "<fields>"

      Examples:
        | type              | fields                   |
        | approved_includes | Approved Includes        |
        | compile           | Compile Path             |
        | memory_errors     | Memory Errors Path       |
        | coverage          | Main Path                |
        | unit              | Unit                     |
        | i_o               | Input Path               |
        | performance       | Performance              |
        | script            | Script Path              |


  Rule: Script tests blocks must have a script path
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    @javascript
    Scenario Outline: Valid script test block
      And I create a new test with type "script"
      And with the name "test1"
      And with the points "10"
      Then I should see the "script" dynamic test block partial
      And I add the dynamic text block field with "<script>"
      And I click the "Create Test" button
      And I should see a message saying "Test was successfully created"

      Examples:
        | script        |
        | script.sh     |
        | script.sh 0   |
        | script.sh 1 2 |
    @javascript
    Scenario: Invalid script test block
      And I create a new test with type "script"
      And with the name "test1"
      And with the points "10"
      Then I should see the "script" dynamic test block partial
      And the field is empty
      When I click the "Create Test" button
      And I should not see the test added to the list of tests in assignment1











