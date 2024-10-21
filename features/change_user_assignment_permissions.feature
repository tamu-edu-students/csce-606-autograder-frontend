Feature: Manage user access for each assignment
  As an instructor
  So that I can manage a user’s permissions for each assignment
  I want to add a read, write, and no access privilege checkbox for each assignment under a user

  Background:
    Given the following assignments exist:
      | assignment_name | repository_name   |
      | assignment1     | assignment-1-repo |
      | assignment2     | assignment-2-repo |
      | assignment3     | assignment-3-repo |
    And the following users exist in assignment permissions:
      | name     | role       | 
      | alice    | ta         | 
      | bob      | ta         |
      | charlie  | instructor | 
    And the following permissions exist:
      | user     | assignment         | role          |
      | alice    | assignment-1-repo  | no-permission |
      | alice    | assignment-2-repo  | no-permission |
      | alice    | assignment-3-repo  | read-write    |
      | bob      | assignment-1-repo  | read-write    |
      | bob      | assignment-2-repo  | read-write    |
    And I am logged in as an "instructor" named "charlie"
    And I am on the "Manage Users" page for assignment permissions

  Scenario: Grant a user read access to a single assignment
    When I click on "alice"
    And I "select" "read" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Grant a user write access to a single assignment
    When I click on "alice"
    And I "select" "write" for the assignment "assignment-2-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "read-write" access to the remote "assignment-2-repo" repository

  Scenario: Grant a user read access to all assignments
    When I click on "alice"
    And I select "Select All" for the "read" permission
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "read" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "read" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's read access to all assignments
    When I click on "alice"
    And I select "Revoke All" for the "read" permission
    And I click "Save Changes"
    Then I should see that "alice" has "no-permission" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "no-permission" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "no-permission" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's read access to a single assignment
    When I click on "alice"
    And I "deselect" "read" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "no-permission" access to the remote "assignment-1-repo" repository

  Scenario: Remove a user's write access to a single assignment
    When I click on "bob"
    And I "deselect" "write" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Remove a user's write access to all assignments
    When I click on "bob"
    And I select "Revoke All" for the "write" permission
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-2-repo" repository

  Scenario: Grant a user write access to all assignments
    When I click on "alice"
    And I select "Select All" for the "write" permission
    And I click "Save Changes"
    Then I should see that "alice" has "read-write" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "read-write" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "read-write" access to the remote "assignment-2-repo" repository