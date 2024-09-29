Feature: Create a new test case
    As an instructor or TA with write access to an assignment
    So that I can test some functionality of a student code
    I want to add a new test case to an assignment

    Scenario: Tests with unknown type
            When I create a new test with type "invalid"
            Then I should see an error message saying "Unknown test type: invalid"

    Rule: All test must have non-empty name, points, type, and if applicable, target attributes
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
                | type              | name          | points | target      |
                | approved_includes | test1         | 10     | target1.cpp |
                | compile           | test2         | 10     | target2.cpp |
                | memory_errors     | test3         | 10     | target3.cpp |
                | coverage          | test4         | 10     | target4.cpp |
                | unit              | test5         | 10     | target5.cpp |
                | i/o               | test6         | 10     | target6.cpp |
                | performance       | test7         | 10     | target7.cpp |
                | script            | test8         | 10     | target8.cpp |

        Scenario Outline: Exempt tests missing target
            When I create a new test with type "<type>"
            And with the name "<name>"
            And with the points "<points>"
            Then I should see the new test the list of assignment tests

            Examples:
                | type              | name          | points | target |
                | compile           | test1         | 10     |        |
                | memory_errors     | test2         | 10     |        |
                | script            | test3         | 10     |        |

        Scenario Outline: Non-exempt tests missing target
            When I create a new test with type "<type>"
            And with the name "<name>"
            And with the points "<points>"
            Then I should see an error message saying "Missing attribute: target"

            Examples:
                | type              | name          | points | target |
                | approved_includes | test1         | 10     |        |
                | coverage          | test2         | 10     |        |
                | unit              | test3         | 10     |        |
                | i/o               | test4         | 10     |        |
                | performance       | test5         | 10     |        |

        Scenario Outline: Tests missing one of [name, points, type]
            When I create a new test with type "<type>"
            And with the name "<name>"
            And with the points "<points>"
            And with the target "<target>"
            Then I should see an error message saying "Missing attribute: <attribute>"

            Examples:
                | type              | name          | points | target      |
                |                   | test1         | 10     | target1.cpp |
                | memory_errors     |               | 10     | target2.cpp |
                | script            | test3         |        | target3.cpp |
                | approved_includes |               | 10     | target4.cpp |
                | coverage          | test2         |        | target5.cpp |

        Scenario Outline: Tests missing multiple required attributes
            When I create a new test with type "<type>"
            And with the name "<name>"
            And with the points "<points>"
            Then I should see an error message saying "Missing attributes: <attribute1>, <attribute2>"

            Examples:
                | type              | name          | points | target      |
                |                   |               | 10     |             |
                | memory_errors     |               |        |             |
                | unit              | test3         |        |             |
                | approved_includes |               |        | target4.cpp |
                | coverage          |               | 10     |             |


    Rule: Coverage test blocks contain exactly one main and may contain sources
        Background:
            Given the following assignments exist:
                | assignment_name | repository_name   |
                | assignment1     | assignment-1-repo |
            And the assignment contains no tests
            And I am logged in as an "instructor"
            And I am on the "Assignment Management" page for "assignment1"
            And I create a new test with type "coverage"
            And with the points "10"
            And with the target "target1.cpp"

        Scenario: Test block has main and no source
            Given the test block contains only the line "main: main.cpp"
            When I click the "Save" button
            Then I should see the test added to the list of tests in assignment1
            And I should see the test block contain the line "main: main.cpp"
            And I should see the target inserted as the source line: "source: target1.cpp"

        Scenario: Test block has main and empty source
            Given the test block contains the lines "main: main.cpp" and "source:"
            When I click the "Save" button
            Then I should see the test added to the list of tests in assignment1
            And I should see the test block contain the lines "main: main.cpp" and "source:"
            And I should see the target inserted as the source line: "source: target1.cpp"

        Scenario: Test block has main and single source
            Given the test block contains the lines "main: main.cpp" and "source: source.cpp"
            When I click the "Save" button
            Then I should see the test added to the list of tests in assignment1
            And I should see the test block contain the lines "main: main.cpp" and "source: source.cpp"

        Scenario: Test block has main and multiple sources
            Given the test block contains the lines "main: main.cpp" and "source: source1.cpp source2.cpp"
            When I click the "Save" button
            Then I should see the test added to the list of tests in assignment1
            And I should see the test block contain the lines "main: main.cpp" and "source: source1.cpp source2.cpp"

        Scenario: Test block is empty
            Given the test block is empty
            When I click the "Save" button
            Then I should see an error message saying "Invalid test block: missing main"
            And I should not see the test added to the list of tests in assignment1

        Scenario: Test block has no main
            Given the test block contains the line "source: source.cpp"
            When I click the "Save" button
            Then I should see an error message saying "Invalid test block: missing main"
            And I should not see the test added to the list of tests in assignment1




