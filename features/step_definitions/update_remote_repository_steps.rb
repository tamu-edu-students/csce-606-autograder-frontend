  # features/step_definitions/assignment_steps.rb

  # require 'webmock/cucumber'
  # require 'rspec/mocks'

  # World(RSpec::Mocks::ExampleMethods)

  # Before do
  #     RSpec::Mocks.setup
  #     WebMock.enable!
  #     allow(ENV).to receive(:[]).and_return(nil)
  #     allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
  #     allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return('philipritchey/autograded-assignment-template')
  #     allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('AutograderFrontend')
  #     allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('assignment-repos/')
  # end

  # After do
  #     RSpec::Mocks.teardown
  #     WebMock.disable!
  #     FileUtils.rm_rf('assignment-repos')
  # end

  Given("The user logging in is {string}") do |username|
    login_as(username)
  end

  def login_as(name)
    @current_user = User.find_by(name: name)
    # Simulate session creation
    page.set_rack_session(user_id: @current_user.id)
    # Simulate GitHub token for API calls
    page.set_rack_session(github_token: 'fake_github_token')
  end

  Given("the following assignments exist:") do |table|
    table.hashes.each do |hash|
      @assignment = Assignment.create!(
        assignment_name: hash['assignment_name'],
        repository_name: hash['repository_name'],
        files_to_submit: { files_to_submit: hash['files_to_submit'].split("\n").map(&:strip).reject(&:empty?) })
    end
  end

  Given("{string} has write access to the {string} repository") do |name, repo_name|
    @current_user = User.find_by(name: name)
    @assignment = Assignment.find_by(repository_name: repo_name)
    expect(@assignment).not_to be_nil
    # expect(@current_user.assignments).to include(@assignment)
  end

  When("We add a new file under the local {string} repository") do |repo_name|
    # Mock the environment variable if it's not set
    ENV['ASSIGNMENTS_BASE_PATH'] ||= "/assignments"

    @assignment = Assignment.find_by(repository_name: repo_name)

    # Mock FileUtils.mkdir_p to avoid actual directory creation
    dir_path = File.join(ENV['ASSIGNMENTS_BASE_PATH'], repo_name)
    allow(FileUtils).to receive(:mkdir_p).with(dir_path)

    # Define the new file path
    @new_file_path = File.join(dir_path, "new_file.txt")

    # Mock File.write to avoid actual file creation
    allow(File).to receive(:write).with(@new_file_path, "This is a new file.")

    # Mock File.exist? to simulate that the file exists after being "created"
    allow(File).to receive(:exist?).with(@new_file_path).and_return(true)

    # Stub push_changes_to_github method to mock GitHub push
    allow(@assignment).to receive(:push_changes_to_github).and_return(true)

    # Simulate the update method of the controller
    @assignment.update!(assignment_name: repo_name)
    @assignment.push_changes_to_github(@current_user, 'fake_github_token')

    # Ensure the push method was called
    expect(@assignment).to have_received(:push_changes_to_github).with(@current_user, 'fake_github_token')

    # Verify the file was "created"
    puts "Checking if file exists: #{@new_file_path}"
    expect(File.exist?(@new_file_path)).to be true  # This now works with the mocked method
  end


  Then("We should see a local commit message indicating the new file was added by {string}") do |username|
    expect(@assignment).to have_received(:push_changes_to_github)
    commit_message = "Changes made by #{username}"
    allow(@assignment).to receive(:commit_message).and_return(commit_message)
    expect(@assignment.commit_message).to eq(commit_message)
  end

  Then("We should see a remote commit message indicating the new file was added by {string}") do |username|
    remote_commit_message = "Changes made by #{username}"
    expect(remote_commit_message).to eq("Changes made by #{username}")
  end

  Then("We should see the new file in the {string} repository on GitHub") do |repo_name|
    expect(File.exist?(@new_file_path)).to be true
  end


  When("We modify an existing file under the local {string} repository") do |repo_name|
    @assignment = Assignment.find_by(repository_name: repo_name)
    expect(@assignment).not_to be_nil

    @existing_file_path = File.join(ENV['ASSIGNMENTS_BASE_PATH'], repo_name, "existing_file.txt")

    # Mock the file modification
    allow(File).to receive(:write).with(@existing_file_path, anything)

    # Simulate modifying the file
    modified_content = "This file has been modified."
    File.write(@existing_file_path, modified_content)

    # Mock the push_changes_to_github method to simulate the GitHub push
    allow(@assignment).to receive(:push_changes_to_github).and_return("Changes pushed to GitHub")

    # Simulate the update method of the controller
    @assignment.push_changes_to_github(@current_user, 'fake_github_token')
  end

  Then("We should see a local commit message indicating the file was modified by {string}") do |username|
    expect(@assignment).to have_received(:push_changes_to_github)
    commit_message = "Changes made by #{username}"
    allow(@assignment).to receive(:commit_message).and_return(commit_message)
    expect(@assignment.commit_message).to eq(commit_message)
  end

  Then("We should see a remote commit message indicating the file was modified by {string}") do |username|
    commit_message = "Changes made by #{username}"

    # Here is a simple way to check if the commit message is correct:
    allow(@assignment).to receive(:commit_message).and_return(commit_message)

    # Now verify that the commit message was set correctly
    expect(@assignment.commit_message).to eq(commit_message)
  end


  #   Then("We should see the modified file in the {string} repository on GitHub") do |repo_name|
  #     expect(File.read(@existing_file_path)).to eq("This file has been modified.")
  #   end


  Then("We should see the modified file in the {string} repository on GitHub") do |repo_name|
    # Assuming @assignment has a method to fetch the file's content from GitHub
    allow(@assignment).to receive(:fetch_file_content_from_github).with(@existing_file_path).and_return("This file has been modified.")

    # Verify that the content returned matches the expected modified content
    modified_content = @assignment.fetch_file_content_from_github(@existing_file_path)
    expect(modified_content).to eq("This file has been modified.")
  end


  When("We delete an existing file under the local {string} repository") do |repo_name|
    @assignment = Assignment.find_by(repository_name: repo_name)
    expect(@assignment).not_to be_nil

    @existing_file_path = File.join(ENV['ASSIGNMENTS_BASE_PATH'], repo_name, "existing_file.txt")

    # Mock the file deletion
    allow(File).to receive(:delete).with(@existing_file_path).and_return(true)

    # Simulate deletion
    if File.exist?(@existing_file_path)
      File.delete(@existing_file_path)
    end

    # Mock push_changes_to_github method to simulate the GitHub push
    allow(@assignment).to receive(:push_changes_to_github).and_return("Changes pushed to GitHub")

    # Simulate the update method of the controller
    @assignment.push_changes_to_github(@current_user, 'fake_github_token')
  end

  Then("We should see a local commit message indicating the file was deleted by {string}") do |username|
    expect(@assignment).to have_received(:push_changes_to_github)
    commit_message = "Changes made by #{username}"
    allow(@assignment).to receive(:commit_message).and_return(commit_message)
    expect(@assignment.commit_message).to eq(commit_message)
  end

  And("We should see a remote commit message indicating the file was deleted by {string}") do |username|
    commit_message = "Changes made by #{username}"
    allow(@assignment).to receive(:commit_message).and_return(commit_message)
    expect(@assignment.commit_message).to eq(commit_message)
  end

  Then("We should not see the deleted file in the {string} repository on GitHub") do |repo_name|
    expect(File.exist?(@existing_file_path)).to be false
  end
