Feature: Add a user to the organization
    As an administrator of the CSCE 120 GitHub organization
    So that I can manage who can interact with the application and how
    I want to be able to add users to the GitHub organization through the application

    Background:
        Given I am logged in as an "instructor"
        And I am on the "Manage Users" page

    Scenario Outline: Add a user to the organization
        When I add a new user with the username "<username>" and the role "<role>"
        Then I should see that "<username>" is now a member of the GitHub organization
        And I should see that "<username>" has "<access>" access to all repositories

        Examples:
            | username | role       | access     |
            | alice    | ta         | read       |
            | bob      | instructor | read-write |

    Scenario Outline: Add a user to the organization with invalid role
        When I add a new user with the username "<username>" and the role "<role>"
        Then I should see an error message saying "Invalid role: <role>"

        Examples:
            | username | role    |
            | alice    | student |
            | bob      | admin   |

    Scenario: Add a user to the organization with an existing username
        Given A user with the username "alice"
        When I add a new user with the username "alice" and the role "ta"
        Then I should see the error message "Username already exists"