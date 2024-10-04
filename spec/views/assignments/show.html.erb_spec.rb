require 'rails_helper'

RSpec.describe "assignments/show", type: :view do
  before(:each) do
    assign(:assignment, Assignment.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
