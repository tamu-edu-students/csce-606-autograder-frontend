Feature: User management
    As an administrator of the CSCE 120 GitHub organization
    So that I can manage who can interact with the application and how
    I want to be able to do so through modifying users' roles within
        the GitHub organization through the application

    Scenario: Instructors can manage users
        Given I am am logged in with the "instructor" role
        When I try to visit the "Manage Users" page
        Then I should see the "Manage Users" page

    Scenario: TAs cannot manage users
        Given I am am logged in as a TA
        When I try to visit the "Manage Users" page
        Then I should see an error message

    Scenario: See user's assignment permissions
        Given the following users exist:
            | username       | role       | access     |
            | alice          | ta         | read       |
            | bob            | ta         | read       |
            | charlie        | instructor | read-write |
        And I am am logged in as "charlie"
        And I am on the "Manage Users"
        When I click on the "alice" user
        Then I should see a list of checkboxes indicating the assignments
            that "alice" has write access to
        And I should see a "Give write access to all assignments" button
        And I should see a "Revoke write access to all assignments" button

    # Add scenarios describing an assignment view that
    # allows instructors to manage all permissions for
    # a given assignment