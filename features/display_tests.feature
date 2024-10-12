Feature: Display test cases
    As an instructor or TA with read access to an assignment
    So that I can review details of the existing test cases of an assignment
    I want to fetch and display the existing test cases in the assignment

    Background:
        Given I am logged in as an "organization member"
        And I am on the "Assignment Management" page for "assignment1"

    Scenario: Display test cases
        And I bypass the remote update for tests
        Given there is a test case of type "<type>"
        And the test case has name "<name>"
        When I click on that test case
        Then I should see the correct details of the test case

        Examples:
            | type              | name  |
            | approved_includes | test1 |
            | compile           | test2 |
            | memory_errors     | test3 |
            | coverage          | test4 |
            | unit              | test5 |
            | i/o               | test6 |
            | performance       | test7 |
            | script            | test8 |