And("I should see a text field at the top of the scrollable block") do
    expect(page).to have_css(".scrollable-container .new-test-grouping-form .form-control", visible: true)
  end

  And("I fill in the text field with {string}") do |grouping_name|
    fill_in "New Test Grouping", with: grouping_name
  end

  And("I click the add button") do
    find(".new-test-grouping-form .btn-primary").click
  end
  
  Then("I should see {string} in the list of test case groupings") do |grouping_name|
    within(".scrollable-container") do
      expect(page).to have_content(grouping_name)
    end
  end

  And("I should see a success message {string}") do |message|
    expect(page).to have_content(message)
  end

  And("I should see an error message {string}") do |message|
    expect(page).to have_content(message)
  end

  And("the following test case groupings exist for {string}:") do |assignment_name, table|
    assignment = Assignment.find_by(assignment_name: assignment_name)
  
    table.hashes.each do |row|
        grouping_name = row["grouping_name"]
        TestGrouping.create!(name: grouping_name, assignment: assignment)
    end
  end
  
  
  