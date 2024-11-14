Feature: Live update for points
    As a CSCE 120 GitHub organization member
    So that I can update the points for a test case live without having to explicitly save it
    I want a single points editor text field

    Background: Assignments in the GitHub organization
        Given the following assignments exist:
            | assignment_name | repository_name   |
            | assignment1     | assignment1 |
        And I am logged in as an "instructor"
        And the following test case groupings exist for "assignment1":
            | grouping_name       |
            | Basic Functionality |
            | Edge Cases          |
        And "<Test Name>" test exists in "<Grouping Name>" in order
            |Test Name              | Grouping Name       |
            |Test_BF_1              | Basic Functionality |
            |Test_EC_1              | Edge Cases          |
        And I am on the "Assignment Management" page for "assignment1"

    @javascript
    Scenario Outline: Verify the points editor icon functionality and live updates
        Then I should see a points editor and test name for each test in their respective test groupings
        When I click on the point editor for "<Test Name>"
        And I enter "<points>" in the text field
        And I click outside the text field or press Enter
        Then the points for "<Test Name>" should update to "<points>"

        Examples:
            | Test Name | points |
            | Test_BF_1 | 5     |
            | Test_EC_1 | 3     |