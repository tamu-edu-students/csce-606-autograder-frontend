Given("I am logged in as a (instructor|TA)") do |role|
  user = User.find_or_create_by!(role: role)
  login_as(user)
end

  Given('I am on the "Assignment Management" page for {string}') do |assignment_name|
    FileItem = Struct.new(:name, :path, :type, :children)
    stub_request(:get, "https://api.github.com/repos/AutograderFrontend/assignment-1-repo/contents/tests/c++")
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
  stub_request(:get, "https://api.github.com/repos/AutograderFrontend/assignment-1-repo/contents/tests/c++/io_tests").
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
    @assignment = Assignment.find_or_create_by!(assignment_name: assignment_name)
    # mkdrir_p
    FileUtils.mkdir_p(File.join(@assignment.local_repository_path))
    visit assignment_path(@assignment)

    expect(page).to have_content(@assignment.assignment_name)
  end

  Given("there is a test case of type {string}") do |type|
    click_link('Add new test')
    select type, from: 'Test type'
  end

  When("I click on that test case") do
    click_on "Create Test"
  end

  Then("I should see the correct details of the test case") do
    expect(page).to have_content('Test was successfully created')
  end
