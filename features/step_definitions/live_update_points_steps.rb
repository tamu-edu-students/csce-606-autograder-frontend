Then("I should see a points editor and test name for each test in their respective test groupings") do
    # Loop through each `.test-info` element in the DOM
    all('.test-info').each do |test_info|
      # Check for the presence of a test name link within `.test-info`
      expect(test_info).to have_css('a.text-link', text: /\d+\) Test_\w+_\d+/) # Regex to match names like "1) Test_BF_1"
      
      # Check for the presence of the points editor form
      expect(test_info).to have_css('form.inline-form')
      expect(test_info).to have_css('input.points-input')
    end
  end
  
  When('I click on the point editor for {string} and enter {string} in the text field') do |test_name, points|
    test = Test.find_by(name: test_name)
    test2 = Test.find_by(name: "Test_EC_1")
    within('.test-grouping-list') do
      # First, find all test cards and iterate through them
      all('.test-card').each do |test_card|
        # Find the link within the test card
        link = test_card.find('.test-info a.text-link') 
        # The link text includes position number, so we need to check if it contains our test name
        if link.text.include?("#{test.position}) #{test_name}")
          # Once we find the right test card, click its points input and set the value
          input = test_card.find('.points-input')
          input.click
          input.set(points)
          break
        end
      end
    end
  end
  
  # Simulate clicking outside the input field or pressing Enter
  When('I click outside the text field or press Enter') do
    find('#totalPoints').click
    # Add a small wait for AJAX
    sleep 0.5
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