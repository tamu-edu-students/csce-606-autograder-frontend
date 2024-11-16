Then('the {string} file should be updated with the {string} files for {string}') do |file_name, file_list, repository_name|
    repository_path = File.join('assignment-repos', repository_name)
    run_autograder_path = File.join(repository_path, file_name)

    expected_files = file_list.split(",").map(&:strip).reject(&:empty?).join(" ")
    puts "#{expected_files}"

    expected_content = "files_to_submit=( #{expected_files} )"

    expect(File).to exist(run_autograder_path), "Expected #{file_name} to exist but it does not."
    expect(File.read(run_autograder_path)).to include(expected_content), "Expected #{file_name} to contain the correct files to submit."
  end


  Then('the changes should be pushed to the remote repository') do
    allow_any_instance_of(Assignment).to receive(:push_changes_to_github).and_call_original
    expect_any_instance_of(Assignment).to receive(:push_changes_to_github).with(instance_of(User), instance_of(String))
  end
