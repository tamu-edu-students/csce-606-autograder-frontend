 
  Then("I should see the file directory of {string}") do |assignment_name|
    assignment = Assignment.find_by!(assignment_name: assignment_name)
    expect(page).to have_content("File Tree for /tests folder")
    expect(page).to have_selector(".file-tree")
  end
  
  Then("I should see a directory dropdown displayed") do
    expect(page).to have_selector(".folder-name[onclick='toggleFolder(this)']")
  end
