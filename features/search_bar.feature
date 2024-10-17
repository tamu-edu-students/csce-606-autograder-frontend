Feature: Search functionality on the assignments page

    Background:
    Given the following assignments exist:
        | assignment_name   | repository_name   |
        | assignment-1      | assignment-1-repo |
        | assignment-2      | assignment-2-repo |
        | assignment-3      | assignment-3-repo |


    Scenario: User searches for an assignment by name
        Given I am on the "Assignments" page
        When I fill in "query" with "assignment-1"
        And I click the "Search Assignment" button
        Then I should see "assignment-1-repo" in the list of assignments

    Scenario: User searches with no matching assignments
        Given I am on the "Assignments" page
        When I fill in "query" with "random"
        And I click the "Search Assignment" button
        Then I should see a message indicating no matching assignments found

    Scenario: User clears the search results
        Given I am on the "Assignments" page
        And I have searched for "assignment-2"
        When I clear the search bar
        Then I should see the full list of assignments

    Scenario: User performs an empty search
        Given I am on the "Assignments" page
        When I click the search button without entering any text
        Then I should see the full list of assignments