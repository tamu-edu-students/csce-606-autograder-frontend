Feature: Search functionality on the assignments page

    Background:
    Given the following assignments exist:
        | repository_name   |
        | assignment-1-repo |
        | assignment-2-repo |
        | assignment-3-repo |

    Scenario: User searches for an assignment by name
        Given I am on the assignments page
        When I enter "assignment-1" into the search bar
        And I click the search button
        Then I should see "assignment-1-repo" in the list of assignments

    Scenario: User searches with no matching assignments
        Given I am on the assignments page
        When I enter "random" into the search bar
        And I click the search button
        Then I should see a message indicating no matching assignments found

    Scenario: User clears the search results
        Given I am on the assignments page
        And I have searched for "assignment-2"
        When I clear the search bar
        Then I should see the full list of assignments

    Scenario: User performs an empty search
        Given I am on the assignments page
        When I click the search button without entering any text
        Then I should see the full list of assignments