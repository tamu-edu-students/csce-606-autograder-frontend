class Assignment < ActiveRecord::Base
    has_many :tests
    def generate_tests_file
        # should determine the language that is wanted
        language_folder = "tests/#{self.language}"

        # makes sure the foulder exists if not make it
        FileUtils.mkdir_p(language_folder)

        # Defining  the path for the .tests file
        tests_file_path = "#{language_folder}/#{self.title.parameterize}.tests"

        # Opening the file for writing the stuff
        File.open(tests_file_path, 'w') do |file|
        self.tests.each do |test|
            file.write(format_test(test))
            file.write("\n\n")
        end
        end
    end

    private

    def format_test(test)
        test_spec = <<~TEST_SPEC
        /*
        @name: #{test.name}
        @points: #{test.points}
        @target: #{test.target}
        @type: #{test.test_type}
        #{format_optional_attributes(test)}
        */
        <test>
        #{test.body}
        </test>
        TEST_SPEC
        
        return test_spec
    end

    def format_optional_attributes(test)
        optional_attrs = ""
        optional_attrs += "@include: #{test.include_files}\n" if test.include_files.present?
        optional_attrs += "@number: #{test.number}\n" if test.number.present?
        optional_attrs += "@show_output: #{test.show_output}\n" if test.show_output.present?
        optional_attrs += "@skip: #{test.skip}\n" if test.skip.present?
        optional_attrs += "@timeout: #{test.timeout}\n" if test.timeout.present?
        optional_attrs += "@visibility: #{test.visibility}\n" if test.visibility.present?
        return optional_attrs
    end
end