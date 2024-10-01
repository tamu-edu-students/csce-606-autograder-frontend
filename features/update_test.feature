Feature: Update an existing test case
    As an instructor or TA with write access to an assignment
    So that I can test some functionality of student code
    I want to update an existing test case in an assignment

    Scenario Outline: Update an existing test case
        Given I am logged in as an instructor
        And I have created an assignment with a test case of type "<type>"
        When I update the test case with valid input
        Then I should see the updated test case in the assignment

        Examples:
            | type              |
            | approved_includes |
            | compile           |
            | memory_errors     |
            | coverage          |
            | unit              |
            | i/o               |
            | performance       |
            | script            |

    Scenario Outline: Update an existing test case with invalid input
        Given I am logged in as an instructor
        And I have created an assignment with a test case of type "<type>"
        When I update the test case with invalid input
        Then I should see an error message

        Examples:
            | type              |
            | approved_includes |
            | compile           |
            | memory_errors     |
            | coverage          |
            | unit              |
            | i/o               |
            | performance       |
            | script            |

    