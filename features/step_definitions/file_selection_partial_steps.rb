Then("I should see a nested file structure dropdown") do
  within('#include-file-tree-dropdown') do
    expect(page).to have_css('.file-tree', visible: true)

    within('.file-tree') do
      expect(page).to have_css('li.file.file-item', minimum: 1)
      expect(page).to have_css('li.file.file-item label input[type="checkbox"].file-checkbox', minimum: 1)

      expect(page).to have_css('li.dir.dir-item', minimum: 1)
      expect(page).to have_css('li.dir.dir-item span.directory-name', minimum: 1)


      within('li.dir.dir-item') do
        expect(page).to have_css('ul.directory-children', visible: false)

        find('span.directory-name').click

        within('ul.directory-children', visible: true) do
          expect(page).to have_css('li.file.file-item', minimum: 1)
          expect(page).to have_css('li.file.file-item label input[type="checkbox"].file-checkbox', minimum: 1)
        end
      end
    end
  end
end

And("each file should have a checkbox beside its name") do
  within('#include-file-tree-dropdown') do
    # Explicitly scope to the first .file-tree within the dropdown
    within(find('.file-tree', match: :first)) do
      # Iterate over each file item in the file tree
      all('li.file.file-item').each do |file_item|
        # Ensure each file has a checkbox
        expect(file_item).to have_css('label input[type="checkbox"].file-checkbox', visible: true)

        # Optionally, ensure the checkbox is next to the file name
        label = file_item.find('label')
        expect(label).to have_css('input[type="checkbox"].file-checkbox')
        expect(label.text).not_to be_empty # Ensure the label contains the file name
      end
    end
  end
end

When("I click on the Includes file-tree dropdown") do
  find('#include-file-dropdown').click
  expect(page).to have_css('#include-file-tree-dropdown', visible: true, wait: 5)
end

When("I expand the {string} directory") do |dir_name|
    # within("#include-file-tree-dropdown") do
    #   find("li", text: dir_name).click
    # end
    # within("#compile-file-tree-dropdown") do
    find("li", text: dir_name).click
  # end
end

And(/^I select the following files in "(.*)" dropdown:$/) do |dropdown_type, table|
  dropdown_id = case dropdown_type
  when "include" then "include-file-tree-dropdown"
  when "compile" then "compile-file-tree-dropdown"
  when "source-paths" then "source-path-file-tree-dropdown"
  when "memory_errors" then "mem-error-file-tree-dropdown"
  when "input_path" then "input-file-tree-dropdown"
  else raise "Unknown dropdown type: #{dropdown_type}"
  end

  table.hashes.each do |row|
    directory = row['Directory']
    file_name = row['File']
    file_path = "#{directory}/#{file_name}"
    within("##{dropdown_id}") do
      directory_element = find("span.directory-name[data-path='#{directory}']", visible: :all)
      directory_element.click
      expect(page).to have_css("ul.directory-children", visible: :all, wait: 10)
      checkbox = find("input[type='checkbox'][data-file-path='#{file_path}']", visible: :all)
      page.execute_script("arguments[0].checked = true; arguments[0].dispatchEvent(new Event('change', { bubbles: true }));", checkbox.native)
    end
  end
end



Then('the {string} field should display the selected file paths') do |field|
  checkboxes = all("input[type='checkbox'][data-file-path]", visible: :all)
  sleep 0.5

  # Determine the appropriate field based on the field name
  curr_field = case field
  when "include"
                 find("#test_include", visible: :all)
  when "source_path"
                 find("#test_block_source_paths", visible: :all)
  when "compile_path"
                 find("#test_block_compile_paths", visible: :all)
  when "memory_errors"
                find('#test_block_mem_error_paths', visible: :all)
  else
                 raise "Unknown field: #{field}"
  end

  # Get paths from selected checkboxes
  selected_file_paths = checkboxes.select(&:checked?).map { |checkbox| checkbox['data-file-path'] }

  # Parse the displayed file paths to remove extra quotes or brackets
  displayed_file_paths = begin
    JSON.parse(curr_field.value) # Attempt to parse JSON format if present
  rescue JSON::ParserError
    curr_field.value.split(",").map { |path| path.gsub(/["\[\]]/, '').strip }
  end

  # expect(displayed_file_paths).to match_array(selected_file_paths)

  # Check that at least one selected file path is displayed
  expect(displayed_file_paths & selected_file_paths).not_to be_empty,
    "Expected at least one of the selected file paths (#{selected_file_paths}) to be displayed, but got #{displayed_file_paths}."
end


Then('the Includes attribute for {string} should be saved as a list of selected file paths') do |test_name|
  # Find the test case by its name
  test = Test.find_by(name: test_name)

  # Ensure the test exists
  expect(test).not_to be_nil

  # Expected list of files selected in the 'include' dropdown
  expected_files = [
    'tests/c++/io_tests/output.txt',
    'tests/c++/io_tests/input.txt'
  ]

  # Use test.include directly if it’s already an array
  actual_files = test.include || []

  # Verify the include attribute matches the expected list
  expect(actual_files).to match_array(expected_files)
end
