Then("I should see an asterisk next to the {string} field") do |field|
  asterisk_element = find("label[for='test_#{field.downcase}'] span", visible: true)
  expect(asterisk_element).to have_content('*')
end
When("I enter {string} in the {string} field") do |value, field|
  fill_in "test_#{field.downcase}", with: value
end
When("I select {string} as the {string} type") do |type, field|
  select type, from: "test_#{field.downcase}"
end
Then("the {string} button should be active") do |button_text|
  button = find("input[type='submit'][value='#{button_text}']")
  expect(button).not_to be_disabled
end
Then("the {string} button should remain disabled") do |button_text|
  button = find("input[type='submit'][value='#{button_text}']")
  expect(button).to be_disabled
end

When("I attempt to fill in fields as follows:") do |table|
  create_test_button = find("input[type='submit'][value='Create Test']") # Locate button by text explicitly

  table.hashes.each do |row|
    # Reset the form fields at the beginning of each iteration
    fill_in("test_name", with: "")
    fill_in("test_points", with: "")
    select("Please select a test type", from: "test_type") # Reset to default if empty
    fill_in("test_target", with: "")

    # Fill in each field if it has a value in the table
    fill_in("test_name", with: row['name']) if row['name'] && !row['name'].empty?
    fill_in("test_points", with: row['points']) if row['points'] && !row['points'].empty?

    # Set type if provided
    if row['type'] && !row['type'].empty?
      select(row['type'], from: "test_type")
    end

    fill_in("test_target", with: row['target']) if row['target'] && !row['target'].empty?

    # Expect "Create Test" button to remain disabled
    expect(create_test_button).to be_disabled
  end
end

When("I clear the {string} field") do |field|
  fill_in "test_#{field.downcase}", with: ""
end
