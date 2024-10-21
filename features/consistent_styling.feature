Feature: Links styled as buttons with clear labels
  As a CSCE 120 GitHub organization member
  So that I can navigate the app easily
  I want to see links styled as buttons with clear, descriptive labels

  Background:
    Given I am logged in as an "instructor" named "alice"

  Scenario Outline: Verify links styled as buttons with clear labels on various pages
    Given I am on the "<page>" page
    Then primary navigation elements should be links styled as buttons with clear labels

    Examples:
      | page          |
      | Assignments   |
      | Login         |
      | Users         |
