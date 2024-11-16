  Feature: Radio button for single-choice file selection
    As a CSE 120 organization member
    So that I can select the particular file I want to upload for single-choice fields
    I want the file-selection-tree dropdown to have a radio button beside each file name for selection

    Background:
    Given the following assignments exist:
      | assignment_name | repository_name | files_to_submit                        |
      | assignment1     | assignment1     | tests/unit_test.js \n tests/input.txt \n main.cpp  |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"

    @javascript
    Scenario: Viewing the file selection dropdown
        When I select a test type of "<type>"
        And We click on "<field>"
        Then I should see a nested file structure dropdown
        And I should see a "<selector>" beside each file name
        Examples:
        | type           | field               | selector     |
        | unit           | include             | checkbox     |
        | coverage       | source_paths        | checkbox     |
        | coverage       | main_path           | radio_button |
        | compile        | compile_paths       | checkbox     |
        | memory_errors  | memory_errors_paths | checkbox     |
        | i_o            | input_path          | radio_button |
        | i_o            | output_path         | radio_button |
    

    @javascript
    Scenario: Selecting files from different subdirectories with checkboxes and radio buttons
        When I select the "<field>" option
        And I expand the "io_tests" directory
        And I select the following files:
        | Directory             | File           |
        | tests/c++/io_tests    | input.txt      |
        | tests/c++/io_tests    | output.txt     |
        | tests/c++/io_tests    | readme.txt     |
        Then the "<field>" field should display the selected file paths if it is a checkbox
        And if it is a radio button, it should display only the path of the last selected file
        Examples:
        | field    | selector       |
        | include  | checkbox       |
        | target   | radio_button   |

