Given("the following assignments exist:") do |table|
    table.hashes.each do |assignment_data|
      @assignment = Assignment.create!(assignment_name: assignment_data['assignment_name'], repository_name: assignment_data['repository_name'])
    end
  end
  
  
Given("the assignment contains no tests") do
    @assignment.tests.destroy_all
end

When("I add a new unit test called {string} with {int} point targeting {string} and the test code {string} and the test type {string} and the include files {string}") do |name, points, target, test_code, test_type, include_files|
    visit new_assignment_test_path(@assignment)
    fill_in 'Name', with: name
    fill_in 'Points', with: points
    fill_in 'Target', with: target
    # fill_in 'Test Code', with: test_code
    # fill_in 'Test Type', with: test_type
    # fill_in 'Include Files', with: include_files
    click_button 'Create Test'
end

Then("I should see a success message") do
    expect(page).to have_content("Test was successfully created")
end

Then("the .tests file should contain the properly formatted test") do
    file_content = File.read("#{@assignment.repository_name}/.tests")

    # file_content = File.read("/path/to/your/tests/file")
    expect(file_content).to include("Test1")
    expect(file_content).to include("code.cpp")
    expect(file_content).to include("EXPECT_TRUE(is_prime(3));")  
end
  