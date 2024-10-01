Feature: Update remote assignment repository
    As an instructor (or TA)
    So that I can update the assignment
    I want to push any assignment changes to the remote GitHub repository

    Background:
        Given I am logged in as "alice"
        And an the name "csce-120-hw1" exists
        And I have write access to the "csce-120-hw1" repository

    Scenario: New file is added to local repository
        When I add a new file under the local "csce-120-hw1" repository
        Then I should see a local commit message indicating the new file was added by "alice"
        And I should see a remote commit message indicating the new file was added by "alice"
        And I should see the new file in the "csce-120-hw1" repository on GitHub

    Scenario: Existing file is modified in local repository
        When I modify an existing file under the local "csce-120-hw1" repository
        Then I should see a local commit message indicating the file was modified by "alice"
        And I should see a remote commit message indicating the file was modified by "alice"
        And I should see the modified file in the "csce-120-hw1" repository on GitHub

    Scenario: Existing file is deleted in local repository
        When I delete an existing file under the local "csce-120-hw1" repository
        Then I should see a local commit message indicating the file was deleted by "alice"
        And I should see a remote commit message indicating the file was deleted by "alice"
        And I should not see the deleted file in the "csce-120-hw1" repository on GitHub