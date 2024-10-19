require 'rails_helper'

RSpec.describe TestGrouping, type: :model do
  let!(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'assignment-1') }

  describe 'validations' do
    it 'validates presence of name' do
      test_grouping = TestGrouping.new(assignment: assignment, name: nil)
      expect(test_grouping).not_to be_valid
      expect(test_grouping.errors[:name]).to include("Test grouping name can't be blank")
    end

    it 'validates uniqueness of name scoped to assignment' do
      TestGrouping.create!(assignment: assignment, name: 'Unique Name')
      duplicate_test_grouping = TestGrouping.new(assignment: assignment, name: 'Unique Name')
      expect(duplicate_test_grouping).not_to be_valid
      expect(duplicate_test_grouping.errors[:name]).to include("A test case grouping with this name already exists")
    end
  end

  describe 'associations' do
    it 'belongs to an assignment' do
      test_grouping = TestGrouping.new(name: 'Group Name', assignment: assignment)
      expect(test_grouping.assignment).to eq(assignment)
    end
  end

  describe 'acts_as_list' do
    it 'orders test groupings by position within the assignment' do
      group1 = TestGrouping.create!(name: 'Group 1', assignment: assignment)
      group2 = TestGrouping.create!(name: 'Group 2', assignment: assignment)

      expect(group2.position).to be > group1.position
    end
  end
end
