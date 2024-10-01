Feature: Create a new test case
  As an instructor or TA with write access to an assignment
  So that I can test some functionality of a student code
  I want to add a new test case to an assignment

  Scenario: Tests with unknown type
    When I create a new test with type "invalid"
    Then I should see an error message saying "Unknown test type: invalid"

  Scenario: Changing test type asks for confirmation
    Given I am on the "Assignment Management" page for "assignment1"
    And I create a new test with type "unit"
    And there is text in the test block
    When I change the test type to "compile"
    Then I should be prompted with a warning that the test block will be cleared
    And I should see a button to confirm

  Rule: All tests must have non-empty name, points, type, and if applicable, target attributes
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
        | assignment2     | assignment-2-repo |
        | assignment3     | assignment-3-repo |
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    Scenario Outline: Test has required attributes
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And with the target "<target>"
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

    Scenario Outline: Exempt tests missing target
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      Then I should not see any missing attribute error messages

      Examples:
        | type          | name  | points | target |
        | compile       | test1 | 10     |        |
        | memory_errors | test2 | 10     |        |
        | script        | test3 | 10     |        |

    Scenario Outline: Non-exempt tests missing target
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      Then I should see an error message saying "Missing attribute: target"

      Examples:
        | type              | name  | points | target |
        | approved_includes | test1 | 10     |        |
        | coverage          | test2 | 10     |        |
        | unit              | test3 | 10     |        |
        | i/o               | test4 | 10     |        |
        | performance       | test5 | 10     |        |

    Scenario Outline: Tests missing one of [name, points, type]
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      And with the target "<target>"
      Then I should see an error message saying "Missing attribute: <attribute>"

      Examples:
        | type              | name  | points | target      |
        |                   | test1 | 10     | target1.cpp |
        | memory_errors     |       | 10     | target2.cpp |
        | script            | test3 |        | target3.cpp |
        | approved_includes |       | 10     | target4.cpp |
        | coverage          | test2 |        | target5.cpp |

    Scenario Outline: Tests missing multiple required attributes
      When I create a new test with type "<type>"
      And with the name "<name>"
      And with the points "<points>"
      Then I should see an error message saying "Missing attributes: <attribute1>, <attribute2>"

      Examples:
        | type              | name  | points | target      |
        |                   |       | 10     |             |
        | memory_errors     |       |        |             |
        | unit              | test3 |        |             |
        | approved_includes |       |        | target4.cpp |
        | coverage          |       | 10     |             |


  Rule: Test names must be unique
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And the assignment contains the following test:
        | test_name | test_type | test_points | test_target | test_block     |
        | test1     | unit      | 10          | target1.cpp | main: main.cpp |
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"

    Scenario: Test names are unique
      When I create a new test with type "unit"
      And with the name "test0"
      And with the points "10"
      And with the target "target1.cpp"
      Then I should not see an error message saying "Test name must be unique"

    Scenario: Test names are not unique
      When I create a new test with type "unit"
      And with the name "test1"
      And with the points "10"
      And with the target "target1.cpp"
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
      And I click the "Save" button
      Then I should see the test added to the list of tests in assignment1
      And I should see a message saying "Test added successfully"

      Examples:
        | script        |
        | script.sh     |
        | script.sh 0   |
        | script.sh 1 2 |

    Scenario: Invalid script test block
      Given the test block has the field "Script Path"
      And the field is empty
      When I click the "Save" button
      Then I should see an error message saying "Invalid test block: missing script path"
      And I should not see the test added to the list of tests in assignment1

  Rule: Coverage test blocks must have a main path and may have source paths
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"
      And I create a new test with type "coverage"
      And with the name "test1"
      And with the points "10"

    Scenario Outline: Valid coverage test block
      Given the test block contains the fields "Main Path" and "Source Path(s)"
      When I fill in the field "Main Path" with "<main>"
      And I fill in the field "Source Path(s)" with "<source>"
      And I click the "Save" button
      Then I should see the test added to the list of tests in assignment1
      And I should see a message saying "Test added successfully"

      Examples:
        | main     | source                  |
        | main.cpp |                         |
        | main.cpp | source.cpp              |
        | main.cpp | source1.cpp source2.cpp |

    Scenario Outline: Invalid coverage test block
      Given the test block contains the fields "Main Path" and "Source Path(s)"
      When I fill in the field "Main Path" with "<main>"
      And I fill in the field "Source Path(s)" with "<source>"
      And I click the "Save" button
      Then I should not see the test added to the list of tests in assignment1
      And I should see an error message saying "Invalid test block: missing main"

      Examples:
        | main | source     |
        |      |            |
        |      | source.cpp |

  Rule: I/O test blocks must have input and output paths
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"
      And I create a new test with type "i/o"
      And with the name "test1"
      And with the points "10"

    Scenario: Valid I/O test block
      Given the test block contains the fields "Input Path" and "Output Path"
      When I fill in the field "Input Path" with "input.txt"
      And I fill in the field "Output Path" with "output.txt"
      And I click the "Save" button
      Then I should see the test added to the list of tests in assignment1
      And I should see a message saying "Test added successfully"

    Scenario Outline: Invalid I/O test block
      Given the test block contains the fields "Input" and "Output"
      When I fill in the field "Input" with "<input>"
      And I fill in the field "Output" with "<output>"
      And I click the "Save" button
      Then I should not see the test added to the list of tests in assignment1
      And I should see an error message saying "Invalid test block: missing input"

      Examples:
        | input     | output     |
        |           | output.txt |
        | input.txt |            |
        |           |            |


