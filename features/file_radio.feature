Feature: Radio button for single-choice file selection
    As a CSE 120 organization member
    So that I can select the particular file I want to upload for single-choice fields
    I want the file-selection-tree dropdown to have a radio button beside each file name for selection

    Background:
    Given the following assignments exist:
      | assignment_name | repository_name | files_to_submit                                    |
      | assignment1     | assignment1     | tests/unit_test.js \n tests/input.txt \n main.cpp  |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"


    @javascript
    Scenario: Viewing the file selection dropdown
        When I create a new test with type "<type>"
        Then Clicking on "<field>" should render "<selector>" type dropdown
         Examples:
        | type           | field               | selector     |
        | unit           | include             | checkbox     |
        | coverage       | source_path         | checkbox     |
        | coverage       | main_path           | radio        |
        | i_o            | input_path          | radio        |
        | i_o            | output_path         | radio        |
        | compile        | compile_path        | checkbox     |
        | memory_errors  | memory_errors_path  | checkbox     |
        


      @javascript
      Scenario: Selecting single file in a radio-type dropdown
        When I create a new test with type "<type>"
        Then Clicking on "<field>" should render "radio" type dropdown
        And I expand the "io_tests" directory
        And We select the following files in "<field>" dropdown:
          | Directory             | File           |
          | tests/c++/io_tests    | input.txt      |
          | tests/c++/io_tests    | output.txt     |
        Then The "<field>" field should display the selected file path
        And Only one file should be selected in the "<field>" dropdown
        
        Examples:
          | type           | field               |
          | i_o            | output_path         |
          | i_o            | input_path          |
          | coverage       | main_path           |


      @javascript
      Scenario: Selecting multiple files in checkbox-type dropdown
        When I create a new test with type "<type>"
        Then Clicking on "<field>" should render "checkbox" type dropdown
        And I expand the "io_tests" directory
        And I select the following files in "<type>" dropdown:
          | Directory             | File           |
          | tests/c++/io_tests    | input.txt      |
          | tests/c++/io_tests    | output.txt     |
          | tests/c++/io_tests    | readme.txt     |
        Then the "<type>" field should display the selected file paths
        Examples:
          |type                 | field               |
          | include             | include             |
          | memory_errors       | memory_errors_path  |
    


      