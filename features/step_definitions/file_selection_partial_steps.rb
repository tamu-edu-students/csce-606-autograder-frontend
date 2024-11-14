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

When("I expand the {string} directory") do |dir_name|
  within("#include-file-tree-dropdown") do
    find("li", text: dir_name).click
  end
end

And(/^I select the following files:$/) do |table|
  table.hashes.each do |row|
    directory = row['Directory']
    file_name = row['File']
    file_path = "#{directory}/#{file_name}"
    within("#include-file-tree-dropdown") do
      directory_element = find("span.directory-name[data-path='#{directory}']", visible: :all)
      directory_element.click
      expect(page).to have_css("ul.directory-children", visible: :all, wait: 10)
      checkbox = find("input[type='checkbox'][data-file-path='#{file_path}']", visible: :all)
      page.execute_script("arguments[0].checked = true; arguments[0].dispatchEvent(new Event('change', { bubbles: true }));", checkbox.native)
    end
  end
end


Then(/^the include field should display the selected file paths$/) do
  checkboxes = all("input[type='checkbox'][data-file-path]", visible: :all)
  sleep 0.5

  include_field = find("#test_include", visible: :all)

  selected_file_paths = checkboxes.select(&:checked?).map { |checkbox| checkbox['data-file-path'] }
  displayed_file_paths = include_field.value.split(",").map(&:strip)

  expect(displayed_file_paths).to match_array(selected_file_paths)
end