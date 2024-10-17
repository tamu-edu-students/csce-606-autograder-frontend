Rule: Test blocks must prompt user for correct fields
    Background:
      Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment-1-repo |
      And the assignment contains no tests
      And I am logged in as an "instructor"
      And I am on the "Assignment Management" page for "assignment1"
    Scenario Outline: Test block contains correct fields
      When I create a new test with type "<type>"
      And with the name "test1"
      And with the points "10"
      And with the target "target1.cpp"
      Then the test block should contain the fields "<fields>"
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