
Then("Clicking on {string} should render {string} type dropdown") do |field, selector |
  case field
  when "include"
      find('#include-file-dropdown').click
      expect(page).to have_css('#include-file-tree-dropdown', visible: true, wait: 5)

      within('#include-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type=#{selector}]", visible: true)
        end
      end
  when "source_path"
      find('#test_block_source_paths').click
      expect(page).to have_css('#source-path-file-tree-dropdown', visible: true, wait: 5)

      within('#source-path-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type=#{selector}]", visible: true)
        end
      end
  when "main_path"
      find('#test_block_main_path').click
      expect(page).to have_css('#main-path-file-tree-dropdown', visible: true, wait: 5)

      within('#main-path-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type=#{selector}]", visible: true)
        end
      end
  when "compile_path"
      find('#test_block_compile_paths').click
      expect(page).to have_css('#compile-file-tree-dropdown', visible: true, wait: 5)

      within('#compile-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type=#{selector}]", visible: true)
        end
      end
  when "memory_errors_path"
      find('#test_block_mem_error_paths').click
      expect(page).to have_css('#mem-error-file-tree-dropdown', visible: true, wait: 5)

      within('#mem-error-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty # Ensure file items exist

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type=#{selector}]", visible: true)
        end
      end
  when "input_path"
      find('#test_block_input_path').click
      expect(page).to have_css('#input-file-tree-dropdown', visible: true, wait: 5)

      within('#input-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty # Ensure file items exist

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type=#{selector}]", visible: true)
        end
      end
  when "output_path"
      find('#test_block_output_path').click
      expect(page).to have_css('#output-file-tree-dropdown', visible: true, wait: 5)

      within('#output-file-tree-dropdown') do
        file_items = all('li.file.file-item')
        expect(file_items).not_to be_empty # Ensure file items exist

        file_items.each do |file_item|
          expect(file_item).to have_css("input[type='radio']", visible: true)
        end
      end
  else
      click_link link
  end
end

When("We click on {string}") do |field|
  dropdown_id = case field
  when "input_path" then "input-file-tree-dropdown"
  when "output_path" then "output-file-tree-dropdown"
  when "main_path" then "main-path-file-tree-dropdown"
  else raise "Unknown field: #{field}"
  end

  find("#{dropdown_id}").click
  expect(page).to have_css("##{dropdown_id}", visible: true, wait: 5)
end

And("We select the following files in {string} dropdown:") do |dropdown_type, table|
  dropdown_id = case dropdown_type
  when "input_path" then "input-file-tree-dropdown"
  when "output_path" then "output-file-tree-dropdown"
  when "main_path" then "main-path-file-tree-dropdown"
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

      radio_button = find("input[type='radio'][data-file-path='#{file_path}']", visible: :all)
      page.execute_script("arguments[0].checked = true; arguments[0].dispatchEvent(new Event('change', { bubbles: true }));", radio_button.native)
    end
  end
end


Then("The {string} field should display the selected file path") do |field|
  field_id = case field
  when "input_path" then "test_block_input_path"
  when "output_path" then "test_block_output_path"
  when "main_path" then "test_block_main_path"
  else raise "Unknown field: #{field}"
  end

  radio_buttons = all("input[type='radio'][data-file-path]", visible: :all)

  # Ensure only one radio button is selected
  selected_file_path = radio_buttons.find(&:checked?)['data-file-path']

  # Validate the displayed field value
  field_element = find("##{field_id}", visible: :all)
  expect(field_element.value).to eq(selected_file_path)
end

Then("Only one file should be selected in the {string} dropdown") do |dropdown_type|
  dropdown_id = case dropdown_type
  when "input_path" then "input-file-tree-dropdown"
  when "output_path" then "output-file-tree-dropdown"
  when "main_path" then "main-path-file-tree-dropdown"
  else raise "Unknown dropdown type: #{dropdown_type}"
  end

  within("##{dropdown_id}") do
    selected_files = all("input[type='radio'][data-file-path]", visible: :all).select(&:checked?)
    expect(selected_files.count).to eq(1)
  end
end
