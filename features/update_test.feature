Feature: Update an existing test case
    As an instructor or TA with write access to an assignment
    So that I can test some functionality of student code
    I want to update an existing test case in an assignment

    @javascript
    Scenario: Test type cannot be updated
        Given I am logged in as an "instructor"
        Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
        Given I am on the "Assignment Management" page for "assignment1"
        And I have created a test case of type "approved_includes"
        When I view the test
        Then I should see the test type as a read-only text field

    @javascript
    Scenario Outline: Update an existing test case
        Given I am logged in as an "instructor"
        Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
        Given I am on the "Assignment Management" page for "assignment1"
        And I have created a test case of type "<type>"
        When I update the test case with valid input
        Then I should see the updated test case in the assignment

        Examples:
            | type              |
            | approved_includes |
            | compile           |
            | memory_errors     |
            | coverage          |
            | unit              |
            | i_o               |
            | performance       |
            | script            |

    @javascript
    Scenario Outline: Update an existing test case with invalid input
        Given I am logged in as an "instructor"
        Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
        Given I am on the "Assignment Management" page for "assignment1"
        And I have created a test case of type "<type>"
        When I update the test case with invalid input
        Then I should see an error message

        Examples:
            | type              |
            | approved_includes |
            | compile           |
            | memory_errors     |
            | coverage          |
            | unit              |
            | i_o               |
            | performance       |
            | script            |

