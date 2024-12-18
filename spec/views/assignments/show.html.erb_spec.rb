require 'rails_helper'

RSpec.describe "assignments/show.html.erb", type: :view do
  let(:assignment) { Assignment.create!(
    assignment_name: 'Assignment 1',
    repository_name: "assignment-1",
    files_to_submit: { files_to_submit: [ 'main.cpp', 'code.cpp' ] }) }
  let(:test_grouping) { assignment.test_groupings.create!(name: 'Test Grouping 1') }
  let(:test_case) { assignment.tests.create!(name: 'Test 1', points: 10, test_type: 'unit', target: 'main.cpp', test_block: { code: 'Test body' }, test_grouping_id: test_grouping.id) }


  before do
    assign(:assignment, assignment)
    assign(:test, test_case)
    assign(:test_groupings, [ test_grouping ])
  end

  it "displays the assignment name" do
    render
    expect(rendered).to have_content("Assignment 1")
  end

  it "displays all the tests for the assignment" do
    render

    expect(rendered).to have_content("Test 1")
    expect(rendered).to match("10.0")
    expect(rendered).to have_content("Unit")
  end

  it "has a link to edit the test" do
    render
    expect(rendered).to have_link(href: assignment_path(assignment, test_id: test_case.id))
  end

  it "has a link to add a new test" do
    render
    expect(rendered).to have_link('Add New Test', href: assignment_path(assignment, test_id: nil))
  end

  it "renders the form to edit the test" do
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_field('Name', with: 'Test 1')
    expect(rendered).to have_field('Points', with: 10.0)
    expect(rendered).to have_select('Target', selected: 'main.cpp')
    expect(rendered).to have_button('Update Test')
  end

  it "renders the delete button when test is persisted" do
    render
    expect(rendered).to have_button('Delete Test')
  end

  it "has a link to create and download ZIP" do
    render
    expect(rendered).to have_link('Export to Gradescope', href: create_and_download_zip_assignment_path(assignment))
  end
end
