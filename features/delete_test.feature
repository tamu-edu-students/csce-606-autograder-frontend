Feature: Delete a test case
    As an instructor or TA with write access to an assignment
    So that I can no longer test some functionality of student code
    I want to delete a test case in an assignment

    Scenario: Delete a test case
        Given I am logged in as an "instructor"
        And I have created an assignment with a test case of type "<type>"
        When I delete the test case
        Then I should be prompted to confirm the deletion
        And I should not see the test case in the assignment