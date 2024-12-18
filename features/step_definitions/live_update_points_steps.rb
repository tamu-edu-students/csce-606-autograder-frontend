include Rails.application.routes.url_helpers
include Rack::Test::Methods

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
    # Locate the test
    test = Test.find_by(name: test_name)
    raise "Test with name #{test_name} not found" unless test

    # Locate the test grouping and assignment
    test_grouping = test.test_grouping
    assignment = test_grouping.assignment

    # Construct the URL
    update_url = update_points_assignment_test_grouping_test_path(assignment, test_grouping, test)
    puts "Update URL: #{update_url}"

    # Send a POST request with the correct parameter structure
    params = {
      test: {
        points: points.to_f
      }
    }
    puts params
    page.driver.post update_url, params

    # Debugging information
    puts "Response: #{response.inspect}"

    # Reload the test and verify the update
    test.reload
    expect(test.points.to_s).to eq(points), "Expected points for #{test_name} to be #{points}, but got #{test.points}"

    puts "Successfully updated points for #{test_name} to #{points}"
  end











  # Simulate clicking outside the input field or pressing Enter
  When('I click outside the text field or press Enter') do
    total_points_element = find('div[data-points-target="totalPoints"]')

    # Click on the element
    total_points_element.click
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
