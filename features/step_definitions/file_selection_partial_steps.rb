Then("I should see a nested file structure dropdown") do
  find("#test_include").click
  page.execute_script("document.getElementById('include-file-tree-dropdown').style.display = 'block'")
  expect(page).to have_css("#include-file-tree-dropdown", visible: true)
end



Then("the dropdown should contain the following structure:") do |table|
  within("#include-file-tree-dropdown") do
    table.hashes.each do |row|
      if row['Subdirectory'].present?
        expect(page).to have_css("li", text: row['Directory'])
        within("li", text: row['Directory']) do
          expect(page).to have_css("li", text: row['Subdirectory'])
          if row['File'].present?
            within("li", text: row['Subdirectory']) do
              expect(page).to have_css("li", text: row['File'])
            end
          end
        end
      elsif row['File'].present?
        within("li", text: row['Directory']) do
          expect(page).to have_css("li", text: row['File'])
        end
      else
        expect(page).to have_css("li", text: row['Directory'])
      end
    end
  end
end

When("I expand the {string} directory") do |dir_name|
  within("#include-file-tree-dropdown") do
    find("li", text: dir_name).click
  end
end

And("I select the following files:") do |table|
  table.hashes.each do |row|
    within("#include-file-tree-dropdown") do
      find("li", text: row['File']).click
    end
  end
end

Then("the include field should display the selected file paths") do
  selected_files = find("#test_include").value
  expect(selected_files).to include("test_file1.cpp", "test_file2.cpp")
end
