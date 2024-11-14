Feature: Regenerate .tests file on test creation/update/deletion
  As an instructor or TA
  So that the .tests remains up to date with any changes
  I want to update the .tests file to reflect every test creation/update/deletion

  @javascript
  Scenario Outline: Create a valid unit test for empty assignment
    Given the following assignments exist:
      | assignment_name | repository_name   | files_to_submit                            |
      | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\ncode.cpp\n |
    And the assignment contains no tests
    And I am logged in as an "instructor" named "sam"
    And I am on the "Assignment Management" page for "assignment1"
    When I add a new unit test called "<name>"
    And I set it to "<points>" points
    And I set the target to "<target>"
    And I fill in the "<type>" test block with "<test_code>"
    And I click the "Create Test" button
    Then I should see a success message
    And the .tests file should contain the properly formatted test
      | type   | name   | points   | target   | test_code   |
      | <type> | <name> | <points> | <target> | <test_code> |

    Examples:
      | type      | name  | points | target   | test_code                                               |
      | unit      | test1 | 1      | code.cpp | EXPECT_FALSE(is_prime(867));                            |
      | unit      | test2 | 1      | code.cpp | EXPECT_TRUE(is_prime(3));EXPECT_FALSE(is_prime(867)); |

  @javascript
  Scenario Outline: Create a valid unit test for non-empty assignment
    Given the following assignments exist:
      | assignment_name | repository_name   | files_to_submit                            |
      | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\ncode.cpp\n |
    And the assignment contains one test
    And I am logged in as an "instructor" named "sam"
    And I am on the "Assignment Management" page for "assignment1"
    When I add a new unit test called "<name>"
    And I set it to "<points>" points
    And I set the target to "<target>"
    And I fill in the "<type>" test block with "<test_code>"
    And I click the "Create Test" button
    Then I should see a success message
    And the .tests file should contain both properly formatted tests
      | type   | name   | points   | target   | test_code   |
      | <type> | <name> | <points> | <target> | <test_code> |

    Examples:
      | type      | name  | points | target   | test_code                                               |
      | unit      | test3 | 1      | code.cpp | EXPECT_TRUE(is_prime(3));EXPECT_FALSE(is_prime(867));   |
      | unit      | test4 | 1      | code.cpp | EXPECT_TRUE(is_even(64));                               |

  @javascript
  Scenario Outline: Delete a unit test
    Given the following assignments exist:
      | assignment_name | repository_name   | files_to_submit                  |
      | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
    And the assignment contains "<number_of_tests>" tests
    And I am logged in as an "instructor" named "sam"
    And I am on the "Assignment Management" page for "assignment1"
    When I delete the "<position>" test
    Then I should see a success message
    And the .tests file should contain the remaining "<remaining_tests>" tests

    Examples:
      | number_of_tests | position | name  | remaining_tests |
      | 1               | 0        | test1 | 0               |
      | 2               | 0        | test1 | 1               |
      | 2               | 1        | test2 | 1               |
      | 3               | 0        | test1 | 2               |
      | 3               | 1        | test2 | 2               |
      | 3               | 2        | test3 | 2               |
