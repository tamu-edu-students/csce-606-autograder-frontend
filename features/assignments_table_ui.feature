 Feature: Improving Assignments table UI for better usability

 Background:
    Given I am on the "Assignments" page
    And the following assignments exist:
        | assignment_name | created_at                          | updated_at                          |
        | assignment1     | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
        | assignment2     | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
        | assignment3     | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |


 Scenario Outline: Assignments table content is left justified with proper buttons
    Then I should see "<Column name>" column left justified
    And I should see "Export to Gradescope" button in each assignment row
    And I should see "Manage Access" button in each assignment row
    And I should not see "Edit" button in each assignment row
    Examples:
        | Column name     |
        | Assignment Name |
        | Created On      |
        | Last Updated    |

 Scenario Outline: The column used for sorting in the Assignments table should be highlighted.
    When I click on the "<Column Name>" column header
    Then I should see "<Column Name>" column highlighted
    Examples:
        | Column name     |
        | Assignment Name |
        | Created On      |
        | Last Updated    |

 Scenario Outline: Assignment name link should redirect to edit assignment view 
    When I click on "assignment1" link
    Then I should be redirected to the "Assignment Management" page for "assignment1"


