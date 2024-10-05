require 'rails_helper'

RSpec.describe Test, type: :model do
  let(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'repo1', repository_url: 'https://github.com/repo1') } # Manually creating an Assignment instance

  describe 'callbacks' do
    context 'after create' do
      it 'calls regenerate_tests_file on the assignment' do
        expect(assignment).to receive(:generate_tests_file).once
        test = Test.new(name: 'Test1', points: 10, assignment: assignment)
        test.save
      end
    end

    context 'after update' do
      it 'calls regenerate_tests_file on the assignment' do
        expect(assignment).to receive(:generate_tests_file).at_least(:twice) # Once for create and once for update
        test = Test.new(name: 'Test1', points: 10, assignment: assignment)
        test.save
        test.update(points: 20)
      end
    end

    context 'after destroy' do
      it 'calls regenerate_tests_file on the assignment' do
        expect(assignment).to receive(:generate_tests_file).at_least(:twice) # Once for create and once for destroy
        test = Test.new(name: 'Test1', points: 10, assignment: assignment)
        test.save
        test.destroy
      end
    end
  end
end
