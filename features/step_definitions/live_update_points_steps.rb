Then('I should see a points editor next to the test name for {string}') do |test_name|
    expect(page).to have_selector('.test-info', text: test_name)
    expect(page).to have_selector('.points-editor', text: 'pts.')
  end
  
  # Simulate clicking on the points editor and entering points
  When('I click on the points editor for {string}') do |test_name|
    test_row = find('.test-info', text: test_name)
    test_row.find('.points-input').click
  end
  
  When('I enter {string} in the text field') do |points|
    fill_in 'test[points]', with: points
  end
  
  # Simulate clicking outside the input field or pressing Enter
  When('I click outside the text field or press Enter') do
    # Simulate a click outside
    find('body').click
    # Or simulate pressing Enter on the input field
    # find('.points-input').send_keys(:enter)
  end
  
  # Verify that the points were updated correctly in the database
  Then('the points for {string} should update to {string}') do |test_name, points|
    test = Test.find_by(name: test_name)
    expect(test.points.to_s).to eq(points)
  end
  
  # Verify that the total points at the top of the page are updated correctly
  Then('the total points at the top should update to {string}') do |total_points|
    expect(page).to have_content("Total Points: #{total_points}")
  end