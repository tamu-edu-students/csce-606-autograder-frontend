require 'git'
require 'octokit'

Given("I am logged in as {string}") do |user_name|
  @user_name = user_name
  # Simulate login or store user info for commits
end

Given("the name {string} exists") do |repo_name|
  @repo_name = repo_name
  # Ensure the repository exists
end

Given("I have write access to the {string} repository") do |repo_name|
end

### Scenario: New file is added to the local repository
When("I add a new file under the local {string} repository") do |repo_name|
  # Create and write content to a new file in the local repo
  @new_file_path = File.join(repo_name, "new_file.txt")
  File.write(@new_file_path, "This is a new file.")

  # Initialize Git and commit the new file locally
  git = Git.open(repo_name)
  git.add(@new_file_path)
  git.commit("Add new file by #{@user_name}")
end

Then("I should see a local commit message indicating the new file was added by {string}") do |user_name|
  # Verify the most recent local commit message
  git = Git.open(@repo_name)
  expect(git.log.first.message).to eq("Add new file by #{user_name}")
end

Then("I should see a remote commit message indicating the new file was added by {string}") do |user_name|
  # Push the changes to the remote repository
  git = Git.open(@repo_name)
  git.push('origin', 'main')

  # Use Octokit to verify the remote commit on GitHub
  client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  latest_commit = client.commits(@repo_name).first
  expect(latest_commit.commit.message).to eq("Add new file by #{user_name}")
end

Then("I should see the new file in the {string} repository on GitHub") do |repo_name|
  # Verify the new file exists on github
  client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  content = client.contents(repo_name, path: 'new_file.txt')
  expect(content).not_to be_nil
end

### Scenario: Existing file is modified in local repository
When("I modify an existing file under the local {string} repository") do |repo_name|
  # Modify the contents of an existing file in the local repository
  @file_path = File.join(repo_name, "existing_file.txt")
  File.write(@file_path, "Modified content.")

  # Stage and commit the changes locally
  git = Git.open(repo_name)
  git.add(@file_path)
  git.commit("Modify existing file by #{@user_name}")
end

Then("I should see a local commit message indicating the file was modified by {string}") do |user_name|
  # Verify the most recent local commit message
  git = Git.open(@repo_name)
  expect(git.log.first.message).to eq("Modify existing file by #{user_name}")
end

Then("I should see a remote commit message indicating the file was modified by {string}") do |user_name|
  # Push the changes to the remote repository
  git = Git.open(@repo_name)
  git.push('origin', 'main')

  # Verify the remote commit message
  client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  latest_commit = client.commits(@repo_name).first
  expect(latest_commit.commit.message).to eq("Modify existing file by #{user_name}")
end

Then("I should see the modified file in the {string} repository on GitHub") do |repo_name|
  # Verify the file's contents on GitHub
  client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  content = client.contents(repo_name, path: 'existing_file.txt')
  expect(Base64.decode64(content.content)).to include("Modified content.")
end

### Scenario: Existing file is deleted in local repository
When("I delete an existing file under the local {string} repository") do |repo_name|
  # Delete the file in the local repository
  @file_path = File.join(repo_name, "existing_file.txt")
  File.delete(@file_path)

  # Stage and commit the deletion locally
  git = Git.open(repo_name)
  git.remove(@file_path)
  git.commit("Delete existing file by #{@user_name}")
end

Then("I should see a local commit message indicating the file was deleted by {string}") do |user_name|
  # Verify the most recent local commit message
  git = Git.open(@repo_name)
  expect(git.log.first.message).to eq("Delete existing file by #{user_name}")
end

Then("I should see a remote commit message indicating the file was deleted by {string}") do |user_name|
  # Push the changes to the remote repository
  git = Git.open(@repo_name)
  git.push('origin', 'main')

  # Verify the remote commit message
  client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  latest_commit = client.commits(@repo_name).first
  expect(latest_commit.commit.message).to eq("Delete existing file by #{user_name}")
end

Then("I should not see the deleted file in the {string} repository on GitHub") do |repo_name|
  # Verify the file no longer exists on github
  client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
  expect { client.contents(repo_name, path: 'existing_file.txt') }.to raise_error(Octokit::NotFound)
end
