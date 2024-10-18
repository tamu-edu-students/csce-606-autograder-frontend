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


  When('I select {string} for the assignment {string}') do |string, string2|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I select {string} for the assignments {string} and {string}') do |string, string2, string3|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I select {string} for all assignments') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I deselect {string} for the assignment {string}') do |string, string2|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I deselect {string} for the assignments {string} and {string}') do |string, string2, string3|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I deselect {string} for all assignments') do |string|
    pending # Write code here that turns the phrase above into concrete actions
  end

  Then('I should see that {string} has {string} to the remote {string} repository') do |string, string2, string3|
    pending # Write code here that turns the phrase above into concrete actions
  end

  When('I click on the {string} link') do |string|
    click_link string
  end

  When('I should see the {string} view') do |string|
    expect(page).to have_css("##{string}")
  end

  When('I click on the {string} grouping') do |string|
    # click on the grouping
    find(".scrollable-container .test-grouping-title", text: string).click
  end

  When('I should see the list of test cases associated with {string}') do |string|
    # expect the .test-list that is in the same div as the test-grouping-title with text {string} to be visible
    expect(find(".scrollable-container .test-grouping-title", text: string).sibling(".test-list")).to be_visible
  end

  When('I click on the {string} test case name') do |string|
    find(".scrollable-container .test-grouping-title", text: string).sibling(".test-list").find(".test-card", text: string).click
  end

  When('I should see the test displayed in the test-form view') do |string|

  end

  When('I click on the {string} button next to {string}') do |string, string2|
    # click on the button next to the test case grouping
    find(".scrollable-container .test-grouping-title", text: string2).find(".button_to").click
  end

  When('I attempt to update an existing test case grouping {string}') do |string|
    TestGrouping.create(name: string, assignment: @assignment)
  end

  Then('I should no longer see {string} in the list of test case groupings') do |string|
    within(".scrollable-container") do
      expect(page).not_to have_content(string)
    end
  end

  Then('I should see a message {string}') do |string|
    expect(page).to have_content(string)
  end

