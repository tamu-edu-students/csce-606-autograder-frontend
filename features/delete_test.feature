Feature: Delete a test case
    As an instructor or TA with write access to an assignment
    So that I can no longer test some functionality of student code
    I want to delete a test case in an assignment

    @javascript
    Scenario: Delete a test case
        Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
        Given I am logged in as an "instructor"
        Given I am on the "Assignment Management" page for "assignment1"
        And I have created a test case of type "<type>"
        When I delete the test case
        And I should not see the test case in the assignment

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