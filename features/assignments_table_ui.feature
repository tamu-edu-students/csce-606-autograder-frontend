Feature: Update Assignments view based on Wireframe
    Background:
        Given the following assignments with creation time exist:
            | assignment_name | repository_name   | created_at                          | updated_at                          |
            | assignment1     | assignment-1-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
            | assignment2     | assignment-2-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
            | assignment3     | assignment-3-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |

    Scenario Outline: Assignments table content is left justified with proper buttons
        Given I am on the "Assignment" page
        Then I should see "Assignment Name" column left justified
        Then I should see "Created On" column left justified
        Then I should see "Last Updated" column left justified
        And I should see "Export to Gradescope" button in each assignment row
        And I should see "Manage Access" button in each assignment row
        And I should not see "Edit" button in each assignment row
    @javascript
    Scenario Outline: The column used for sorting in the Assignments table should be highlighted.
        Given I am on the "Assignment" page
        When I click on the "Assignment Name" column header
        Then I should see "Assignment Name" column highlighted
        When I click on the "Created On" column header
        Then I should see "Created On" column highlighted
        When I click on the "Last Updated" column header
        Then I should see "Last Updated" column highlighted


    Scenario Outline: Assignment name link should redirect to edit assignment view
        Given I am on the "Assignment" page
        When I click on "assignment-1-repo" link
        Then I should be redirected to the Assignment page for "assignment1"
