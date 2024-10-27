Feature: Test block partials rendering according to test type
  As a CSCE 120 GitHub organization member
  So that I can view the suitable test block
  I want to see test block partials correctly rendered according to test types

  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment1       |
        | assignment2     | assignment2       |
        | assignment3     | assignment3       |

  Scenario Outline: The test block partials should be rendered according to the test type
    Given I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    When I select the test type "<type>"
    Then I should see the "<type>" test block partial
    And the test block should contain the fields "<fields>"

      Examples:
        | type              | fields                   |
        | approved_includes | Approved Includes        |
        | compile           | File Path(s)             |
        | memory_errors     | File Path(s)             |
        | coverage          | Main Path,Source Path(s) |
        | unit              | Code                     |
        | i/o               | Input Path,Output Path   |
        | performance       | Code                     |
        | script            | Script Path              |
