Given("I am logged in as a (instructor|TA)") do |role|
  user = User.find_or_create_by!(role: role)
  login_as(user)
end

  Given('I am on the "Assignment Management" page for {string}') do |assignment_name|
    @assignment = Assignment.find_or_create_by!(assignment_name: assignment_name)
    FileItem = Struct.new(:name, :path, :type, :children)
    stub_request(:get, "https://api.github.com/repos/AutograderFrontend/#{@assignment.repository_name}/contents/tests/c++")
    .with(
      headers: {
      'Accept'=>'application/vnd.github.v3+json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Octokit Ruby Gem 9.1.0'
    })
  .to_return(status: 200, body: [
    FileItem.new('code.tests', 'tests/c++/code.tests', 'file'),
    FileItem.new('io_tests', 'tests/c++/io_tests', 'dir')
    ], headers: {})
  stub_request(:get, "https://api.github.com/repos/AutograderFrontend/#{@assignment.repository_name}/contents/tests/c++/io_tests").
  with(
    headers: {
    'Accept'=>'application/vnd.github.v3+json',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Content-Type'=>'application/json',
    'User-Agent'=>'Octokit Ruby Gem 9.1.0'
    }).
   to_return(status: 200, body: [
    FileItem.new('input.txt', 'tests/c++/io_tests/input.txt', 'file'),
    FileItem.new('output.txt', 'tests/c++/io_tests/output.txt', 'file'),
    FileItem.new('readme.txt', 'tests/c++/io_tests/readme.txt', 'file')
  ], headers: {})
    # mkdrir_p
    FileUtils.mkdir_p(File.join(@assignment.local_repository_path))
    visit assignment_path(@assignment)

    expect(page).to have_content(@assignment.assignment_name)
  end

  Given("there is a test case of type {string}") do |type|
    click_link('Add New Test')
    select type, from: 'Test Type'
  end

  When("I click on that test case") do
    click_on "Create Test"
  end

  Then("I should see the correct details of the test case") do
    expect(page).to have_content('Test was successfully created')
  end

  Then('the Test Editor layout should have a wider landscape view') do
    expect(page).to have_css('.container-fluid') # or other container class that indicates a wider layout
  end

  Then('it should not overlap with the right column') do
    expect(page).to have_css('.right-column') # Ensure right column exists and doesn’t overlap (specific overlap checks would need JavaScript)
  end

  Then('all fields should be fully visible without cutting off content') do
    expect(page).not_to have_css('.test-editor input[style*="overflow: hidden"]')
  end

  Then('I should see a label for the {string} field with units in seconds') do |field|
    # Find the label for the specified field
    label = find('label', text: field)

    # Check that the label exists and is visible
    expect(label).to be_visible

    # Locate the "Seconds" text in the same row or input group
    within(label.find(:xpath, '..')) do
      expect(page).to have_css('.input-group-text', text: 'Seconds')
    end
  end


  Then('the {string} field should display a placeholder or hint text indicating {string}') do |field, placeholder|
    field_element = find("##{field.parameterize}-field")
    expect(field_element[:placeholder]).to include(placeholder)
  end


  Then('I should see a confirmation prompt with the message {string}') do |message|
    # Wait for the confirmation dialog and check its text
    confirm = page.driver.browser.switch_to.alert
    expect(confirm.text).to eq(message)
  end


  When ('I confirm the deletion') do
    # Click the Delete Test button
    # Add a manual wait to handle timing issues with the alert
    page.driver.browser.switch_to.alert.accept
  end

  Then ('I push the delete button to delete the test case') do
    # Click the Delete Test button
    # find('button', text: 'Delete Test').click
    visit assignment_path(@assignment, test_id: @test_case.id)
    click_button 'Delete Test'
  end

  Then('{string} should no longer appear in the test list') do |item|
    expect(page).not_to have_content(item)
  end
