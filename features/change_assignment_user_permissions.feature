Feature: Manage user access for each assignment
  As an instructor
  So that I can manage a user’s permissions for each assignment
  I want to add a read, write, and no access privilege checkbox for each assignment under a user

  Background:
    Given the following assignments exist:
      | repository_name   |
      | assignment-1-repo |
      | assignment-2-repo |
      | assignment-3-repo |
    And the following users exist in assignment permissions:
      | name     | role       | assignment1_access | assignment2_access | assignment3_access |
      | alice    | ta         | read               | read               | no-access          |
      | bob      | ta         | read-write         | read-write         | read-write         |
      | charlie  | instructor | read-write         | read-write         | read-write         |
    And I am logged in to view assignment permissions as "charlie"
    And I am on the "Manage Users" page for assignment permissions

  Scenario: Grant write access to a single user
    When I click on "assignment-1-repo"
    And I select "write" for user "alice"
    And I click "Save Changes"
    Then I should see that "alice" has "write" access to the remote "assignment-1-repo" repository

  Scenario: Grant write access to multiple users
    When I click on "assignment-1-repo"
    And I select "write" for users "alice" and "bob"
    And I click "Save Changes"
    Then I should see that "alice" has "write" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-1-repo" repository

  Scenario: Grant write access to all users
    When I click on "assignment-1-repo"
    And I select "write" for all users
    And I click "Save Changes"
    Then I should see that "alice" has "write" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-1-repo" repository
    And I should see that "charlie" has "write" access to the remote "assignment-1-repo" repository

  Scenario: Remove write access from a user for a single assignment
    When I click on "assignment-1-repo"
    And I deselect "write" for user "bob"
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-3-repo" repository

  Scenario: Remove write access from multiple users
    When I click on "assignment-1-repo"
    And I deselect "write" for users "bob" and "alice"
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "no-access" access to the remote "assignment-1-repo" repository

  Scenario: Remove write access from all users
    When I click on "assignment-1-repo"
    And I deselect "write" for all users
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Grant read access to a single user
    When I click on "assignment-1-repo"
    And I select "read" for user "alice"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Grant read access to multiple users
    When I click on "assignment-1-repo"
    And I select "read" for users "alice" and "bob"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Grant read access to all users
    When I click on "assignment-1-repo"
    And I select "read" for all users
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "charlie" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Remove read access from a user 
    When I click on "assignment-1-repo"
    And I deselect "read" for user "bob"
    And I click "Save Changes"
    Then I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository

  Scenario: Remove read access from multiple users 
    When I click on "assignment-1-repo"
    And I deselect "read" for users "bob" and "alice"
    And I click "Save Changes"
    Then I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "no-access" access to the remote "assignment-1-repo" repository

  Scenario: Remove read access from all users 
    When I click on "assignment-1-repo"
    And I deselect "read" for all users
    And I click "Save Changes"
    Then I should see that "alice" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository

  Scenario: Grant no-access to a single user
    When I click on "assignment-1-repo"
    And I select "no-access" for user "alice"
    And I click "Save Changes"
    Then I should see that "alice" has "no-access" access to the remote "assignment-1-repo" repository
   
  Scenario: Grant no-access to multiple users
    When I click on "assignment-1-repo"
    And I select "no-access" for users "alice" and "bob"
    And I click "Save Changes"
    Then I should see that "alice" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository

  Scenario: Grant no-access access to all users
    When I click on "assignment-1-repo"
    And I select "no-access" for all users
    And I click "Save Changes"
    Then I should see that "alice" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "charlie" has "no-access" access to the remote "assignment-1-repo" repository

