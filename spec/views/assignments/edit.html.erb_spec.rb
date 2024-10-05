require 'rails_helper'

RSpec.describe "assignments/edit", type: :view do
  let(:assignment) {
    Assignment.create!()
  }

  before(:each) do
    assign(:assignment, assignment)
  end

  it "renders the edit assignment form" do
    render

    assert_select "form[action=?][method=?]", assignment_path(assignment), "post" do
    end
  end
end
