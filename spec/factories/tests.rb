FactoryBot.define do
    factory :test do
      association :assignment
      association :test_grouping

      sequence(:name) { |n| "Test #{n}" }
      points { 1 }
      test_type { Test::VALID_TEST_TYPES.sample }
      target { "some_target" }
      show_output { false }
      skip { false }
      visibility { "visible" }

      # Default test_block for each test_type
      trait :approved_includes do
        test_type { "approved_includes" }
        test_block { { "approved_includes" => [ "<iostream>", "<vector>" ] } }
      end

      trait :compile do
        test_type { "compile" }
        test_block { { "file_paths" => [ "path/to/file1.cpp", "path/to/file2.cpp" ] } }
        target { nil }
      end

      trait :coverage do
        test_type { "coverage" }
        test_block { { "source_paths" => [ "path/to/source1.cpp", "path/to/source2.cpp" ], "main_path" => "path/to/main.cpp" } }
      end

      trait :io do
        test_type { "i/o" }
        test_block { { "input_path" => "path/to/input.txt", "output_path" => "path/to/output.txt" } }
      end

      trait :memory_errors do
        test_type { "memory_errors" }
        test_block { { "file_paths" => [ "path/to/file1.cpp", "path/to/file2.cpp" ] } }
        target { nil }
      end

      trait :performance do
        test_type { "performance" }
        test_block { { "code" => "// Performance test code here" } }
      end

      trait :script do
        test_type { "script" }
        test_block { { "script_path" => "path/to/script.sh" } }
        target { nil }
      end

      trait :unit do
        test_type { "unit" }
        test_block { { "code" => "// Unit test code here" } }
      end

      # Initialize with a valid test_block based on test_type
      after(:build) do |test|
        if test.test_block.blank?
          test.test_block = case test.test_type
          when "approved_includes"
                              { "approved_includes" => [ "<iostream>" ] }
          when "compile", "memory_errors"
                              { "file_paths" => [ "path/to/file.cpp" ] }
          when "coverage"
                              { "source_paths" => [ "path/to/source.cpp" ], "main_path" => "path/to/main.cpp" }
          when "i/o"
                              { "input_path" => "path/to/input.txt", "output_path" => "path/to/output.txt" }
          when "performance", "unit"
                              { "code" => "// Test code here" }
          when "script"
                              { "script_path" => "path/to/script.sh" }
          end
        end
      end
    end
  end
