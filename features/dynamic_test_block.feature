Feature: Test Block Behavior
    Background: Assignments in the GitHub organization
        Given the following assignments exist:
            | assignment_name | repository_name   |
            | assignment1     | assignment1 |
        Given I am logged in as an "instructor"
        And I am on the "Assignment Management" page for "assignment1"

    Scenario: Display coverage test in text block
        When I select "Coverage" from the test type dropdown
        Then I should see "Coverage test details" in the test block
    
    Scenario: Display compile test in text block
        When I select "Compile" from the test type dropdown
        Then I should see "Compile test details" in the test block
    
    Scenario: Display Approved Includes test in text block
        When I select "Approved Includes" from the test type dropdown
        Then I should see "Approved Includes test details" in the test block
