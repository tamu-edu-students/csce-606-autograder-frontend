# Given("the following assignments exist:") do |table|
#   table.hashes.each do |assignment|
#     Assignment.create!(
#       title: assignment['assignment_name'],
#       repository_name: assignment['repository_name']
#     )
#   end
# end

# And("the assignment contains no tests") do
#   # Ensure the assignment has no tests
#   Assignment.last.tests.delete_all
# end

# And("the assignment contains {int} tests") do |number_of_tests|
#   assignment = Assignment.last
#   assignment.tests = FactoryBot.create_list(:test, number_of_tests, assignment: assignment)
# end

# Given('I am logged in as an "instructor"') do
#   # Assuming you're using Devise or some authentication system
#   @current_user = User.create!(email: "instructor@example.com", role: "instructor")
#   login_as(@current_user)
# end

# Given('I am on the "Assignment Management" page for {string}') do |assignment_name|
#   assignment = Assignment.find_by(title: assignment_name)
#   visit assignment_path(assignment)
# end

# When('I add a new unit test called {string}') do |name|
#   fill_in 'test_name', with: name
# end

# When('I set it to {string} points') do |points|
#   fill_in 'test_points', with: points
# end

# When('I set the target to {string}') do |target|
#   fill_in 'test_target', with: target
# end

# When('I fill in the test block with {string}') do |test_code|
#   fill_in 'test_code', with: test_code
# end

# When('I click the "Create" button') do
#   click_button 'Create Test'
# end

# Then('I should see a success message') do
#   expect(page).to have_content('Test was successfully created')
# end

# Then('the .tests file should contain the properly formatted test') do
#   assignment = Assignment.last
#   tests_file_path = "tests/#{assignment.language}/#{assignment.title.parameterize}.tests"
#   expect(File.read(tests_file_path)).to include("/*")
# end

# Then('the .tests file should contain both properly formatted tests') do
#   assignment = Assignment.last
#   tests_file_path = "tests/#{assignment.language}/#{assignment.title.parameterize}.tests"
#   assignment.tests.each do |test|
#     expect(File.read(tests_file_path)).to include(test.name)
#     expect(File.read(tests_file_path)).to include(test.actual_test)
#   end
# end

# When('I delete the {int} test') do |position|
#   test = Assignment.last.tests[position]
#   test.destroy
# end

# Then('the .tests file should contain the remaining {int} tests') do |remaining_tests|
#   assignment = Assignment.last
#   tests_file_path = "tests/#{assignment.language}/#{assignment.title.parameterize}.tests"
#   expect(assignment.tests.count).to eq(remaining_tests)
#   remaining_tests.each do |test|
#     expect(File.read(tests_file_path)).to include(test.name)
#   end
# end
