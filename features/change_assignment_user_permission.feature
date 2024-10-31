Feature: Manage assignment access for each user
  As an instructor
  So that I can manage a assignment’s permissions for each user
  I want to add a read, write, and no access privilege checkbox for each user under an assignment

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
      | bob      | assignment-3-repo  | read          |
    And I am logged in as an "instructor" named "charlie"
    And I am on the "Manage Assignments" page for user permissions

  Scenario: Grant a single user read access to an assignment 
    When I click on "Manage Access" for "assignment-1-repo"
    And I "select" "read" for the user "alice"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Grant a single user write access to an assignment 
    When I click on "Manage Access" for "assignment-2-repo"
    And I "select" "write" for the user "alice"
    And I click "Save Changes"
    Then I should see that "alice" has "read-write" access to the remote "assignment-2-repo" repository

  Scenario: Grant all users read access to an assignment 
    When I click on "Manage Access" for "assignment-1-repo"
    And I select "Select All" for the "read" permission
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Remove all users read access to an assignment
    When I click on "Manage Access" for "assignment-1-repo"
    And I select "Revoke All" for the "read" permission
    And I click "Save Changes"
    Then I should see that "alice" has "no-permission" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no-permission" access to the remote "assignment-1-repo" repository
   
  Scenario: Remove a single user's read access to an assignment
    When I click on "Manage Access" for "assignment-3-repo"
    And I "deselect" "read" for the user "bob"
    And I click "Save Changes"
    Then I should see that "bob" has "no-permission" access to the remote "assignment-3-repo" repository

  Scenario: Remove a single user's write access to an assignment
    When I click on "Manage Access" for "assignment-3-repo"
    And I "deselect" "write" for the user "alice"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-3-repo" repository

  Scenario: Remove all user's write access to an assignment
    When I click on "Manage Access" for "assignment-3-repo"
    And I select "Revoke All" for the "write" permission
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-3-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-3-repo" repository

  Scenario: Grant all users write access to an assignments
    When I click on "Manage Access" for "assignment-1-repo"
    And I select "Select All" for the "write" permission
    And I click "Save Changes"
    Then I should see that "alice" has "read-write" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read-write" access to the remote "assignment-1-repo" repository
   