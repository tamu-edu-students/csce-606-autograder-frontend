Feature: Create a new assignment
  As an instructor for CSCE 120
  So that I can create autograded assignments for my students
  I want to create a new Git repository under the CSCE 120 GitHub
  organization from the autograded-assignment-template repository

  Scenario: Duplicate repository names should not be allowed
    Given I create an assignment with the name "Homework 1" and the repository "csce-120-hw1" and files "main.cpp\nhelper.cpp\nhelper.h\n"
    When I create an assignment with the name "Homework 1" and the repository "csce-120-hw1" and files "main.cpp\nhelper.cpp\nhelper.h\n"
    Then I should see the error message "must be unique. This repository name is already taken."

  Scenario: TAs with read-only access should not see the "Create Assignment" button
    Given I am logged in as a "ta"
    Then I should not see the "Create Assignment" button


  
