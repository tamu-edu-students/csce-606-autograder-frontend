Feature: Create a new test case
    As an instructor or TA with write access to an assignment
    So that I can test some functionality of a student code
    I want to add a new test case to an assignment

    Background:
        Given the following assignments exist:
            | assignment_name | repository_name   |
            | assignment1     | assignment-1-repo |
            | assignment3     | assignment-2-repo |
            | assignment2     | assignment-2-repo |
        And I am logged in as an "instructor"
        And I am on the "Assignment Management" page for "assignment1"

    Scenario Outline: Correct fields for test type

    Scenario: Create a test of type "approved_includes"

    Scenario: Create a test of type "compile"

    Scenario: Create a test of type "memory_errors"

    Scenario: Create a test of type "coverage"

    Scenario: Create a test of type "unit"

    Scenario: Create a test of type "i/o"

    Scenario: Create a test of type "performance"

    Scenario: Create a test of type "script"



