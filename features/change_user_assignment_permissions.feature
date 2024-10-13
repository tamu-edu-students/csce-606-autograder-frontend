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

  Scenario: Grant a user write access to a single assignment
    When I click on "alice"
    And I select "write" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "write" access to the remote "assignment-1-repo" repository

  Scenario: Grant a user write access to multiple assignments
    When I click on "alice"
    And I select "write" for the assignments "assignment-1-repo" and "assignment-2-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "write" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "write" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "no-access" access to the remote "assignment-3-repo" repository

  Scenario: Grant a user write access to all assignments
    When I click on "alice"
    And I select "write" for all assignments
    And I click "Save Changes"
    Then I should see that "alice" has "write" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "write" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "write" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's write access to a single assignment
    When I click on "bob"
    And I deselect "write" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's write access to multiple assignments
    When I click on "bob"
    And I deselect "write" for the assignments "assignment-1-repo" and "assignment-2-repo"
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's write access to all assignments
    When I click on "bob"
    And I deselect "write" for all assignments
    And I click "Save Changes"
    Then I should see that "bob" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "read" access to the remote "assignment-3-repo" repository

  Scenario: Revoke all access to a user for multiple assignments
    When I click on "alice"
    And I select "no access" for the assignments "assignment-1-repo" and "assignment-2-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "no access" to the remote "assignment-1-repo" repository
    And I should see that "alice" has "no access" to the remote "assignment-2-repo" repository
    And I should see that "alice" has "no access" access to the remote "assignment-3-repo" repository

  Scenario: Revoke all access to a user for all assignments
    When I click on "bob"
    And I select "no access" for all assignments
    And I click "Save Changes"
    Then I should see that "bob" has "no access" to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no access" to the remote "assignment-2-repo" repository
    And I should see that "bob" has "no access" to the remote "assignment-3-repo" repository

Scenario: Grant a user read access to a single assignment
    When I click on "alice"
    And I select "read" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository

  Scenario: Grant a user read access to multiple assignments
    When I click on "alice"
    And I select "read" for the assignments "assignment-1-repo" and "assignment-2-repo"
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "read" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "no access" access to the remote "assignment-3-repo" repository

  Scenario: Grant a user read access to all assignments
    When I click on "alice"
    And I select "read" for all assignments
    And I click "Save Changes"
    Then I should see that "alice" has "read" access to the remote "assignment-1-repo" repository
    And I should see that "alice" has "read" access to the remote "assignment-2-repo" repository
    And I should see that "alice" has "read" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's read access to a single assignment
    When I click on "bob"
    And I deselect "read" for the assignment "assignment-1-repo"
    And I click "Save Changes"
    Then I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's read access to multiple assignments
    When I click on "bob"
    And I deselect "read" for the assignments "assignment-1-repo" and "assignment-2-repo"
    And I click "Save Changes"
    Then I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no-access" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "write" access to the remote "assignment-3-repo" repository

  Scenario: Remove a user's read access to all assignments
    When I click on "bob"
    And I deselect "read" for all assignments
    And I click "Save Changes"
    Then I should see that "bob" has "no-access" access to the remote "assignment-1-repo" repository
    And I should see that "bob" has "no-access" access to the remote "assignment-2-repo" repository
    And I should see that "bob" has "no-access" access to the remote "assignment-3-repo" repository