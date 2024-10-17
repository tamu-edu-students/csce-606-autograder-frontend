Feature: Consistent button styling and clear labels
  As a CSCE 120 GitHub organization member
  So that I understand how to navigate about the app
  I want to see buttons, rather than links, with intuitive labels

  Background:
    Given I am a member of the CSCE 120 GitHub organization


  Scenario: Verify absence of links where buttons are required
    Given I am on the <page> page
    Then I should not see any navigation links
    And all navigation elements should be buttons with clear labels

    Examples:
            | page              |
            | assignments       |
            | tests             |
            | users             |


