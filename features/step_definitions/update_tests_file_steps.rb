Then('the .tests file should contain the properly formatted test') do |test_params|
    expected = <<~TEST_SPEC
    /*
    @name: #{test_params['name']}
    @points: #{test_params['points']}
    @type: #{test_params['type']}
    @target: #{test_params['target']}
    */
    <test>
    #{test_params['test_code']}
    </test>
    TEST_SPEC

    expect(File.read(
        File.join(ENV["ASSIGNMENTS_BASE_PATH"],
        @assignment.repository_name,
        "code.tests"
    ))).to include(expected)
end

Then('the .tests file should contain the remaining {string} tests') do |string|
    # count the number of tests in the file
    file = File.read(
        File.join(ENV["ASSIGNMENTS_BASE_PATH"],
        @assignment.repository_name,
        "code.tests"
    )).to include(expected)
    expect(file.scan(/<test>/).count).to eq(string.to_i)
end