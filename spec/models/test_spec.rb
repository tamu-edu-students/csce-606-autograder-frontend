require 'rails_helper'

RSpec.describe Test, type: :model do
  let(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: "assignment-1") }

  # Create a valid test object to use in multiple examples
  let(:valid_test) do
    Test.new(
      name: 'Test 1',
      points: 10,
      test_type: 'unit',
      target: 'test_target',
      test_block: { code: 'some test code' },
      assignment: assignment
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_test).to be_valid
    end

    it 'is invalid without a name' do
      valid_test.name = nil
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:name]).to include('Missing attribute: name')
    end

    it 'is invalid with a non-unique name within the same assignment' do
      valid_test.save!
      duplicate_test = valid_test.dup
      expect(duplicate_test).to_not be_valid
      expect(duplicate_test.errors[:name]).to include('Test name must be unique')
    end

    it 'is invalid without points' do
      valid_test.points = nil
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:points]).to include('Missing attribute: points')
    end

    it 'is invalid if points are less than or equal to zero' do
      valid_test.points = 0
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:points]).to include('Points must be greater than 0')
    end

    it 'is invalid without a test_type' do
      valid_test.test_type = nil
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:test_type]).to include('Missing attribute: type')
    end

    it 'is invalid with an unknown test_type' do
      valid_test.test_type = 'invalid_type'
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:test_type]).to include('Unknown test type: invalid_type')
    end

    it 'is invalid without a target for specific test types' do
      valid_test.test_type = 'unit'
      valid_test.target = nil
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:target]).to include('Missing attribute: target')
    end

    it 'is valid without a target for compile, memory_errors, script, or style test types' do
      [ 'compile', 'memory_errors', 'script', 'style' ].each do |type|
        valid_test.test_type = type
        valid_test.target = nil
        expect(valid_test).to be_valid
      end
    end

    it 'is invalid without test_block' do
      valid_test.test_block = {}
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:test_block]).to include("can't be blank")
    end
  end

  describe 'default values' do
    it 'sets show_output to false by default' do
      expect(valid_test.show_output).to eq(false)
    end

    it 'sets skip to false by default' do
      expect(valid_test.skip).to eq(false)
    end

    it 'sets timeout to nil by default' do
      expect(valid_test.timeout).to eq(nil)
    end

    it 'sets visibility to visible by default' do
      expect(valid_test.visibility).to eq('visible')
    end
  end

  describe '#get_test_block_string' do
    it 'correct format for approved_includes' do
      valid_test.test_type = 'approved_includes'
      valid_test.test_block = { approved_includes: [ 'include1', 'include2' ] }
      expect(valid_test.get_test_block_string).to eq("\tinclude1\n\tinclude2")
    end

    it 'correct format for compile' do
      valid_test.test_type = 'compile'
      valid_test.test_block = { file_paths: [ 'file1', 'file2' ] }
      expect(valid_test.get_test_block_string).to eq("\tfile1\n\tfile2")
    end

    it 'correct format for memory_errors' do
      valid_test.test_type = 'memory_errors'
      valid_test.test_block = { file_paths: [ 'file1', 'file2' ] }
      expect(valid_test.get_test_block_string).to eq("\tfile1\n\tfile2")
    end

    it 'correct format for coverage' do
      valid_test.test_type = 'coverage'
      valid_test.test_block = { source_paths: [ 'source1', 'source2' ], main_path: 'main' }
      expect(valid_test.get_test_block_string).to eq("\tsource: source1 source2\n\tmain: main")
    end

    it 'correct format for unit' do
      valid_test.test_type = 'unit'
      valid_test.test_block = { code: 
        "EXPECT_FALSE(is_prime(867));\n" \
        "EXPECT_TRUE(is_prime(5309));\n" \
        "EXPECT_TRUE(is_prime(8675309));"
      }
      expect(valid_test.get_test_block_string).to eq(
        "\tEXPECT_FALSE(is_prime(867));\n" \
        "\tEXPECT_TRUE(is_prime(5309));\n" \
        "\tEXPECT_TRUE(is_prime(8675309));"
      )
    end

    it 'correct format for performance' do
      valid_test.test_type = 'performance'
      valid_test.test_block = { code: 
        "size_t cnt = 1;\n" \
        "for (unsigned n = 3; n < 2000000; n++) {\n" \
        "  if (is_prime(n)) cnt++;\n" \
        "}\n" \
        "std::cout << \"  found \" << cnt << \" primes.\" << std::endl;\n" \
        "EXPECT_EQ(cnt, 148933);"
      }
      expect(valid_test.get_test_block_string).to eq(
        "\tsize_t cnt = 1;\n" \
        "\tfor (unsigned n = 3; n < 2000000; n++) {\n" \
        "\t  if (is_prime(n)) cnt++;\n" \
        "\t}\n" \
        "\tstd::cout << \"  found \" << cnt << \" primes.\" << std::endl;\n" \
        "\tEXPECT_EQ(cnt, 148933);"
      )
    end

    it 'correct format for i/o' do
      valid_test.test_type = 'i/o'
      valid_test.test_block = { input_path: 'input.txt', output_path: 'output.txt' }
      expect(valid_test.get_test_block_string).to eq("\tinput: input.txt\n\toutput: output.txt")
    end

    it 'correct format for script' do
      valid_test.test_type = 'script'
      valid_test.test_block = { script_path: 'script.sh' }
      expect(valid_test.get_test_block_string).to eq("\tscript.sh")
    end

    it 'raises an error for an unknown test type' do
      valid_test.test_type = 'invalid_type'
      expect { valid_test.get_test_block_string }.to raise_error('Unknown test type: invalid_type')
    end
  end
end
