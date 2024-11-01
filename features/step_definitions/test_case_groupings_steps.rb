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
    @assignment = Assignment.find_by(assignment_name: assignment_name)

    table.hashes.each do |row|
        grouping_name = row["grouping_name"]
        TestGrouping.create!(name: grouping_name, assignment: @assignment)
    end
  end

  Given('some tests exist in {string} group in order:') do |grouping_name, table|
    grouping = TestGrouping.find_by(name: grouping_name)

    if grouping.nil?
      puts "Test grouping not found."
    end

    table.hashes.each_with_index do |row, index|
      Test.create!(
        name: row["test_name"],
        points: 10,
        test_type: "unit",
        target: "target.cpp",
        position: index + 1,
        test_grouping_id: grouping.id,
        assignment_id: @assignment.id,
        test_block: { code: "assert_equal(...)" }
      )
    end
  end

  When("I expand the {string} test group") do |group_name|
    group_title = find(".test-grouping-title", text: group_name)
    # group_title.click
    page.execute_script("arguments[0].click();", group_title)
  end

  Then("I should see the following tests in {string} group:") do |group_name, table|
    within(:css, ".test-grouping-card", text: group_name) do
      table.hashes.each do |row|
        expect(page).to have_content(row["test_name"])
      end
    end
  end

  When("I move {string} to after {string} in {string} group") do |test_name, target_test_name, group_name|
    # Find the test group container
    group = find(".test-grouping-title", text: group_name).ancestor(".test-grouping-card")
  
    # Find the source and target test cards
    source_test = group.find(".test-card", text: test_name)
    target_test = group.find(".test-card", text: target_test_name)
  
    # Execute JavaScript to simulate the drag-and-drop
    page.execute_script(<<~JS, source_test[:id], target_test[:id])
      function simulateDragAndDrop(sourceId, targetId) {
        const source = document.getElementById(sourceId);
        const target = document.getElementById(targetId);
  
        if (!source || !target) {
          console.error('Source or target element not found');
          return;
        }
  
        const dataTransfer = new DataTransfer();
        const dragStartEvent = new DragEvent('dragstart', {
          bubbles: true,
          cancelable: true,
          dataTransfer: dataTransfer
        });
        source.dispatchEvent(dragStartEvent);
  
        const dropEvent = new DragEvent('drop', {
          bubbles: true,
          cancelable: true,
          dataTransfer: dataTransfer
        });
        target.dispatchEvent(dropEvent);
  
        const dragEndEvent = new DragEvent('dragend', {
          bubbles: true,
          cancelable: true,
          dataTransfer: dataTransfer
        });
        source.dispatchEvent(dragEndEvent);
      }
  
      simulateDragAndDrop(arguments[0], arguments[1]);
    JS
  
    # Wait for the UI update and any potential server processing
    sleep 1
  end
  

  Then("I should see {string} after {string} in {string} group") do |test_name, target_test_name, group_name|
    # Find the test group container
    group = find(".test-grouping-title", text: group_name).ancestor(".test-grouping-card")

    test_names = group.all(".test-card").map(&:text)
    puts test_names # Debug output to verify the order

    # Find the matching entries in the array
    formatted_test_name = test_names.find { |name| name.include?(test_name) }
    formatted_target_name = test_names.find { |name| name.include?(target_test_name) }

    # Verify the positions
    expect(test_names.index(formatted_test_name)).to be > test_names.index(formatted_target_name)
  end

  Then("the positions of the tests in {string} group should be updated correctly") do |group_name|
    # Find the test group in the database
    group = TestGrouping.find_by(name: group_name)
    tests_in_db = group.tests.order(:position)

    # Print positions for debugging
    tests_in_db.each do |test|
      puts "#{test.name} - Position: #{test.position}"
    end

    # Verify that the positions are sequential
    expected_positions = (1..tests_in_db.size).to_a
    actual_positions = tests_in_db.map(&:position)
    expect(actual_positions).to eq(expected_positions)
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

  Given('the following test cases exist in the {string} group:') do |grouping_name, table|
    # Find the correct test grouping by name
    test_grouping = TestGrouping.find_by(name: grouping_name)

    # Ensure the test grouping exists
    raise "Test grouping '#{grouping_name}' not found" if test_grouping.nil?

    # Iterate over the test cases provided in the table and create them
    table.hashes.each do |row|
      # Use the row data to create a test with all necessary attributes
      Test.create!(
        name: row['name'],                   # Validate presence and uniqueness
        points: row['points'],               # Validate presence and numericality
        test_type: row['test_type'],         # Validate inclusion in VALID_TEST_TYPES
        target: row['target'],               # Validate presence unless test_type is exempt
        test_block: row['test_block'],     # Validate presence
        test_grouping: test_grouping,        # Associate the test with the test group
        assignment: test_grouping.assignment # Associate with the assignment
      )
    end
  end


  When('I click on the {string} grouping') do |string|
    # click on the grouping
    @string = string
    find(".scrollable-container .test-grouping-title", text: string).click
  end

  When('I should see the list of test cases associated with {string}') do |string|
    # expect the .test-list that is in the same div as the test-grouping-title with text {string} to be visible
    expect(find(".scrollable-container .test-grouping-title", text: string).sibling(".test-list")).to be_visible
  end

  When('I click on the {string} test case name') do |string|
    # find(".scrollable-container .test-grouping-title", text: @string).sibling(".test-list").find(".test-card", text: string).click
    within(".test-grouping-card") do
        # Click the specific test card with the test case name inside the test-list
        find(".test-card", text: string).click
      end
  end

  When('I should see the test displayed in the test-form view') do |string|
  end

  When('I click on the {string} button next to {string}') do |button_text, group_name|
    within(".scrollable-container") do
      # Log information to confirm the test grouping title is found
      grouping_title = find(".test-grouping-title", text: group_name)
      puts "Found test grouping: #{group_name}"

      # Check if the button exists and print the button text
      if button_text == "✎"
        # Try to find the edit button
        edit_button = grouping_title.find('button', text: button_text)
        puts "Found edit button with text: #{button_text}"

        # Click the edit button
        edit_button.click
        puts "Clicked the edit button for: #{group_name}"

        within("#test-grouping-card-#{grouping_title[:'data-test-grouping-id']}") do
            expect(page).to have_selector('input[name="test_grouping[name]"]', visible: true, wait: 50000000000)
        end
        puts "Edit form with input field appeared for: #{group_name}"
      elsif button_text == "x"
        # For the delete button, same logic can apply
        delete_button = grouping_title.find('button', text: button_text)
        delete_button.click
      else
        raise "Button text not recognized"
      end
    end
  end




  Then('I fill in the test case grouping text field with {string}') do |string|
    # pending # Write code here that turns the phrase above into concrete actions
    within(".scrollable-container") do
        # Find the visible input field for the test grouping name
        fill_in 'test_grouping[name]', with: string
      end
  end

  And('I click the {string} button in scrollable block') do |button_text|
    within(".scrollable-container") do
        # Wait for the Save button to be visible after AJAX renders it
        expect(page).to have_button(button_text, visible: true) # This will wait for the button to appear
        click_button button_text
    end
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
