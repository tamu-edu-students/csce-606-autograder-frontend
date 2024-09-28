Feature: Remove user
    As an administrator of the CSCE 120 GitHub organization
    So that I can manage who can interact with the application and how
    I want to be able to remove users from the GitHub organization through the application

    Background:
        Given the following users exist:
            | username       | role       |
            | alice          | ta         |
            | bob            | instructor |
            | charlie        | instructor |
        Given I am logged in as "charlie"
        And I am on the "Manage Users" page

    Scenario Outline: Remove a user from the organization
        When I remove the user with the username "<username>" and the role "<role>"
        Then I should see that "<username>" is no longer a member of the GitHub organization

        Examples:
            | username | role       |
            | alice    | ta         |
            | bob      | instructor |