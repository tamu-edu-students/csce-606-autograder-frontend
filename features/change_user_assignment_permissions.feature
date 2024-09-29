Feature: Grant or revoke a user's write permissions to an assignment
    As an administrator of the CSCE 120 GitHub organization
    So that I can manage who can interact with the application and how
    I want to be able to grant and revoke a user's write access to a repository through the application

    Background:
        Given the following assignments exist:
            | assignment_name | repository_name   |
            | assignment1     | assignment-1-repo |
            | assignment2     | assignment-2-repo |
            | assignment3     | assignment-3-repo |
        And the following users exist:
            | username       | role       | assignment1_access | assignment2_access | assignment3_access |
            | alice          | ta         | read               | read               | read               |
            | bob            | ta         | read-write         | read-write         | read-write         |
            | charlie        | instructor | read-write         | read-write         | read-write         |
        And I am logged in as "charlie"
        And I am on the "Manage Users" page

    Scenario: Grant a user write access to a single assignment
        When I click on "alice"
        And I select the assignment "assignment-1-repo"
        And I click "Save changes"
        Then I should see that "alice" has "read-write" access to the remote "assignment-1-repo" repository

    Scenario:  Grant a user write access to multiple assignments
        When I click on "alice"
        And I select the assignments "assignment-1-repo" and "assignment-2-repo"
        And I click "Save changes"
        Then I should see that "alice" has "read-write" access to the remote "assignment-1-repo" repository and "assignment-2-repo" repository
        And I should see that "alice" has "read" access to the remote "assignment-3-repo" repository

    Scenario: Grant a user write access to all assignments
        When I click on "alice"
        And I click the "Give write access to all assignments" button
        And I click "Save changes"
        Then I should see that "alice" has "read-write" access to the remote "assignment-1-repo" repository, "assignment-2-repo" repository, and "assignment-3-repo" repository

    Scenario: Remove a user's write access to a single assignment
        When I click on bob
        And I de-select the assignment "assignment-1-repo"
        And I click "Save changes"
        Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
        And I should see that "bob" has "read-write" access to the remote "assignment-2-repo" repository and "assignment-3-repo" repository

    Scenario: Remove a user's write access to multiple assignments
        When I click on bob
        And I de-select the assignments "assignment-1-repo" and "assignment-2-repo"
        And I click "Save changes"
        Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository and "assignment-2-repo" repository
        And I should see that "bob" has "read-write" access to the remote "assignment-3-repo" repository

    Scenario: Remove a user's write access to all assignments
        When I click on bob
        And I click the "Revoke write access to all assignments" button
        And I click "Save changes"
        Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository, "assignment-2-repo" repository, and "assignment-3-repo" repository

