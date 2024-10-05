class Assignment < ApplicationRecord
  has_many :tests
  def generate_tests_file
    FileUtils.mkdir_p(repository_name) unless Dir.exist?(repository_name)

    file_path = "#{repository_name}/.tests"
    File.open(file_path, 'w') do |file|
      tests.each do |test|
        file.puts format_test(test)
      end
    end
  end

  private

  def format_test(test)
    <<~TEST_SPEC
    /*
    @name: #{test.name}
    @points: #{test.points}
    @target: #{test.target}
    @test_type: #{test.test_type}
    @include_files: #{test.include_files}
    */
    <test>
    #{test.test_code}
    </test>
    TEST_SPEC
  end

  # @target is semi-optional (depending on type), but whether it
  # is required or not is checked elsewhere, so it is safe to treat
  # it as optional
  def format_optional_attributes(test)
    optional_attrs = ""
    optional_attributes += "@include_files: #{test.include_files}\n" if test.respond_to?(:include_files)
    optional_attrs += "@target: #{test.target}\n" if test.target.present?
    optional_attrs += "@include: #{test.include_files}\n" if test.include_files.present?
    optional_attrs += "@number: #{test.number}\n" if test.number.present?
    optional_attrs += "@show_output: #{test.show_output}\n" if test.show_output.present?
    optional_attrs += "@skip: #{test.skip}\n" if test.skip.present?
    optional_attrs += "@timeout: #{test.timeout}\n" if test.timeout.present?
    optional_attrs += "@visibility: #{test.visibility}\n" if test.visibility.present?
    optional_attrs
  end
end
