Feature: Update remote assignment repository
    As an instructor (or TA)
    So that I can update the assignment
    I want to push any assignment changes to the remote GitHub repository

    Background:
        Given We have the following users exist in assignment permissions:
        | name     | role       | assignment1_access | assignment2_access | assignment3_access |
        | alice    | ta         | read               | read               | read               |
        | bob      | ta         | read-write         | read-write         | read-write         |
        | charlie  | instructor | read-write         | read-write         | read-write         |
        Given The user logging in is "charlie"
        Given the following assignments exist:
        | assignment_name | repository_name   |
        | csce-120-hw1    | csce-120-hw1      |
        Given "charlie" has write access to the "csce-120-hw1" repository
        

    Scenario: New file is added to local repository
        When We add a new file under the local "csce-120-hw1" repository
        Then We should see a local commit message indicating the new file was added by "charlie"
        And We should see a remote commit message indicating the new file was added by "charlie"
        And We should see the new file in the "csce-120-hw1" repository on GitHub

    Scenario: Existing file is modified in local repository
        When We modify an existing file under the local "csce-120-hw1" repository
        Then We should see a local commit message indicating the file was modified by "charlie"
        And We should see a remote commit message indicating the file was modified by "charlie"
        And We should see the modified file in the "csce-120-hw1" repository on GitHub 

    Scenario: Existing file is deleted in local repository
        When We delete an existing file under the local "csce-120-hw1" repository 
        Then We should see a local commit message indicating the file was deleted by "charlie" 
        And We should see a remote commit message indicating the file was deleted by "charlie" 
        And We should not see the deleted file in the "csce-120-hw1" repository on GitHub