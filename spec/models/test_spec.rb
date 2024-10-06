require 'rails_helper'

RSpec.describe Test, type: :model do
  let(:assignment) { Assignment.create!(assignment_name: 'Assignment 1') }

  # Create a valid test object to use in multiple examples
  let(:valid_test) do
    Test.new(
      name: 'Test 1',
      points: 10,
      test_type: 'unit',
      target: 'test_target',
      actual_test: 'some test code',
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

    it 'is invalid without actual_test' do
      valid_test.actual_test = nil
      expect(valid_test).to_not be_valid
      expect(valid_test.errors[:actual_test]).to include("can't be blank")
    end
  end

  describe 'default values' do
    it 'sets show_output to false by default' do
      expect(valid_test.show_output).to eq(false)
    end

    it 'sets skip to false by default' do
      expect(valid_test.skip).to eq(false)
    end

    it 'sets timeout to 10 by default' do
      expect(valid_test.timeout).to eq(10)
    end

    it 'sets visibility to visible by default' do
      expect(valid_test.visibility).to eq('visible')
    end
  end
end
