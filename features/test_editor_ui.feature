Feature: Test Editor UI Updates
    As a CSCE 120 organization member
    So that I can more intuitively interact with the test editor
    I want to see more accessible styling, more clear labeling, and confirmation for permanent actions

    
    Scenario: Display Test Editor in a landscape layout
        Given I am logged in as an "instructor"
        Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
        Given I am on the "Assignment Management" page for "assignment1"
        Then the Test Editor layout should have a wider landscape view
        And it should not overlap with the right column
        And all fields should be fully visible without cutting off content
    @javascript
    Scenario: Adding units to the Timeout field
        Given I am logged in as an "instructor"
        Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
        Given I am on the "Assignment Management" page for "assignment1"
        Then I should see a label for the "Timeout" field with units in seconds
        And the "Timeout" field should display a placeholder or hint text indicating "seconds"

    @javascript
    Scenario: Confirm deletion of a test case
    Given I am logged in as an "instructor"
        Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n |
        Given I am on the "Assignment Management" page for "assignment1"
        And I have created a test case of type "approved_includes"
        Then I push the delete button to delete the test case
        Then I should see a confirmation prompt with the message "Are you sure?"
        And I confirm the deletion
        Then "Test_BF_1" should no longer appear in the test list