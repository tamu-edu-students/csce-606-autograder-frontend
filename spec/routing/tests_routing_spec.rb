require "rails_helper"

RSpec.describe TestsController, type: :routing do
  describe "routing" do
    let(:assignment_id) { "1" }
    let(:test_id) { "1" }

    it "routes to #index" do
      expect(get: "/assignments/#{assignment_id}/tests").to route_to("tests#index", assignment_id: assignment_id)
    end

    it "routes to #new" do
      expect(get: "/assignments/#{assignment_id}/tests/new").to route_to("tests#new", assignment_id: assignment_id)
    end

    it "routes to #show" do
      expect(get: "/assignments/#{assignment_id}/tests/#{test_id}").to route_to("tests#show", assignment_id: assignment_id, id: test_id)
    end

    it "routes to #edit" do
      expect(get: "/assignments/#{assignment_id}/tests/#{test_id}/edit").to route_to("tests#edit", assignment_id: assignment_id, id: test_id)
    end

    it "routes to #create" do
      expect(post: "/assignments/#{assignment_id}/tests").to route_to("tests#create", assignment_id: assignment_id)
    end

    it "routes to #update via PUT" do
      expect(put: "/assignments/#{assignment_id}/tests/#{test_id}").to route_to("tests#update", assignment_id: assignment_id, id: test_id)
    end

    it "routes to #update via PATCH" do
      expect(patch: "/assignments/#{assignment_id}/tests/#{test_id}").to route_to("tests#update", assignment_id: assignment_id, id: test_id)
    end

    it "routes to #destroy" do
      expect(delete: "/assignments/#{assignment_id}/tests/#{test_id}").to route_to("tests#destroy", assignment_id: assignment_id, id: test_id)
    end
  end
end
