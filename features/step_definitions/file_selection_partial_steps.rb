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

And('the dropdown should contain the following structure:') do |table|
  puts page.html
  within('#include-file-tree-dropdown') do
    expect(page).to have_css('.file-tree', visible: true)
    within ('.file-tree') do
      table.rows.each do |directory, subdirectory, file|
        if file.present?
          expect(page).to have_css("li.file.file-item label", text: file)
        elsif subdirectory.present?
          expect(page).to have_css("li.dir.dir-item > span.directory-name", text: subdirectory)
        else
          expect(page).to have_css("li.dir.dir-item > span.directory-name", text: directory.split('/').last)
        end
      end
    end
  end
end

When("I expand the {string} directory") do |dir_name|
  within("#include-file-tree-dropdown") do
    find("li", text: dir_name).click
  end
end

And('I select the following files:') do |table|
  within('#include-file-tree-dropdown') do
    table.rows.each do |directory, file|
      # Expand the directory if it's not already expanded
      dir_element = find('span.directory-name', text: directory.split('/').last, visible: true)
      dir_element.click
      puts page.html
      puts "#{directory.split('/').last}"
      # Wait for the directory children to be visible
      # expect(page).to have_xpath("//li[contains(@class, 'dir') and contains(@class, 'dir-item')][contains(., '#{directory.split('/').last}')]//ul[contains(@class, 'directory-children')]", visible: true)

      # Find and check the checkbox for the file
      within("li.dir.dir-item:contains('#{directory.split('/').last}') ul.directory-children", visible: true) do
        checkbox = find("input.file-checkbox[data-file-path$='#{file}']")
        checkbox.check
      end
    end
  end
end

Then("the include field should display the selected file paths") do
  selected_files = find("#test_include").value
  expect(selected_files).to include("test_file1.cpp", "test_file2.cpp")
end
