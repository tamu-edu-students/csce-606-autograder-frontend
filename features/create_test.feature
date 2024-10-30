Feature: Create a new test case
    As an instructor or TA with write access to an assignment
    So that I can test some functionality of student code
    I want to add a new test case to an assignment

    Background: Assignments in the GitHub organization
        Given the following assignments exist:
            | assignment_name | repository_name   |
            | assignment1     | assignment1 |
            | assignment2     | assignment2 |
            | assignment3     | assignment3 |
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
        And I add the Actual Test
        And I click the "Create Test" button
        Then I should not see any missing attribute error messages

        Examples:
        | type              | name  | points | target      |
        | approved_includes | test1 | 10     | target1.cpp |
        | compile           | test2 | 10     | target2.cpp |
        | memory_errors     | test3 | 10     | target3.cpp |
        | coverage          | test4 | 10     | target4.cpp |
        | unit              | test5 | 10     | target5.cpp |
        | i/o               | test6 | 10     | target6.cpp |
        | performance       | test7 | 10     | target7.cpp |
        | script            | test8 | 10     | target8.cpp |

    Scenario: Exempt tests missing target
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And I add the Actual Test
      And I click the "Create Test" button
      Then I should not see any missing attribute error messages

      Examples:
        | type          | name  | points | target |
        | compile       | test1 | 10     |        |
        | memory_errors | test2 | 10     |        |
        | script        | test3 | 10     |        |

    Scenario: Non-exempt tests missing target
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And I add the Actual Test
      And I click the "Create Test" button
      Then I should see an error message saying "Missing attributes: target"

      Examples:
        | type              | name  | points | target |
        | approved_includes | test1 | 10     |        |
        | coverage          | test2 | 10     |        |
        | unit              | test3 | 10     |        |
        | i/o               | test4 | 10     |        |
        | performance       | test5 | 10     |        |

    Scenario: Tests missing one of [name, points, type]
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And with the target "<target>"
      And I add the Actual Test
      And I click the "Create Test" button
      Then I should see an error message saying "Missing attributes: <attribute>"

      Examples:
        | type              | name  | points | target      | attribute |
        | memory_errors     |       | 10     | target2.cpp | name      |
        | script            | test3 |        | target3.cpp | points    |
        | approved_includes |       | 10     | target4.cpp | name      |
        | coverage          | test2 |        | target5.cpp | points    |

    Scenario Outline: Tests missing multiple required attributes
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And I add the Actual Test
      And I click the "Create Test" button
      Then I should see an error message saying "Missing attributes: <attribute1>, <attribute2>"

      Examples:
        | type              | name  | points | target      | attribute1 | attribute2 |
        | memory_errors     |       |        | target1.cpp | name       | points     |
        | unit              | test3 |        |             | points     | target     |
        | approved_includes |       |        | target4.cpp | name       | points     |
        | coverage          |       | 10     |             | name       | target     |


  Rule: Test names must be unique
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    Scenario: Test names are unique
      When I create a new test with type "unit"
      And with the name "test0"
      And with the points "10"
      And with the target "target1.cpp"
      And I add the Actual Test
      And I click the "Create Test" button
      Then I should not see an error message saying "Test name must be unique"

    Scenario: Test names are not unique
      When I create a new test with type "unit"
      And with the name "test1"
      And with the points "10"
      And with the target "target1.cpp"
      And I add the Actual Test
      And I click the "Create Test" button
      When I create a new test with type "unit"
      And with the name "test1"
      And with the points "10"
      And with the target "target1.cpp"
      And I add the Actual Test
      And I click the "Create Test" button
      Then I should see an error message saying "Test name must be unique"

  Rule: Test blocks must prompt user for correct fields
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    Scenario Outline: Test block contains correct fields
      When I create a new test with type "<type>"
      And with the name "test1"
      And with the points "10"
      And with the target "target1.cpp"
      And I add the Actual Test
      And I click the "Create Test" button
      Then the test block should contain the fields "<fields>"

      Examples:
        | type              | fields                   |
        | approved_includes | Approved Includes        |
        | compile           | File Path(s)             |
        | memory_errors     | File Path(s)             |
        | coverage          | Main Path,Source Path(s) |
        | unit              | Code                     |
        | i/o               | Input Path,Output Path   |
        | performance       | Code                     |
        | script            | Script Path              |


  Rule: Script tests blocks must have a script path
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"
      And I create a new test with type "script"
      And with the name "test1"
      And with the points "10"


    Scenario Outline: Valid script test block
      Given the test block contains the field "Script Path"
      When I fill in the field with "<script>"
      And I click the "Create Test" button
      Then I should see the test added to the list of tests in assignment1
      And I should see a message saying "Test was successfully created"

      Examples:
        | script        |
        | script.sh     |
        | script.sh 0   |
        | script.sh 1 2 |

    Scenario: Invalid script test block
      Given the test block has the field "Script Path"
      And the field is empty
      When I click the "Create Test" button
      Then I should see an error message saying "Actual test can't be blank"
      And I should not see the test added to the list of tests in assignment1











