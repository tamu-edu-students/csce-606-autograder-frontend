Feature: Initialize run_autograder script when creating an assignment
  As an instructor for CSCE 120
  So that I can create autograded assignments for my students
  I want to initialize the provided files in the autograded-assignment-template repository

  Background: Assignments in the GitHub organization
    Given I am logged in as an "instructor" named "alice"

  Scenario: Successfully update the run_autograder file
    Given I create an assignment with the name "Homework 1" and the repository "csce-120-hw1" and files "main.cpp\nhelper.cpp\nhelper.h\n"
    Then the "run_autograder" file should be updated with the "main.cpp, helper.cpp, helper.h" files for "csce-120-hw1"
    And the changes should be pushed to the remote repository
