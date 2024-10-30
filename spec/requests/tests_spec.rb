# require 'rails_helper'

# RSpec.describe "Tests", type: :request do
#   let!(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: "assignment-1") }
#   let!(:test_case) { assignment.tests.create!(name: 'Test 1', points: 10, test_type: 'unit', target: 'target', test_block: 'Test code') }

#   describe "GET /assignments/:assignment_id/tests" do
#     it "renders the index template" do
#       get assignment_tests_path(assignment)
#       expect(response).to have_http_status(:ok)
#     end
#   end

#   describe "GET /assignments/:assignment_id/tests/:id" do
#     it "shows a specific test" do
#       get assignment_test_path(assignment, test_case)
#       expect(response).to have_http_status(:ok)
#       expect(response.body).to include(test_case.name)
#     end
#   end

#   describe "GET /assignments/:assignment_id/tests/new" do
#     it "renders the new test form" do
#       get new_assignment_test_path(assignment)
#       expect(response).to have_http_status(:ok)
#     end
#   end

#   describe "POST /assignments/:assignment_id/tests" do
#     context "with valid parameters" do
#       it "creates a new test and redirects" do
#         post assignment_tests_path(assignment), params: { test: { name: 'New Test', points: 20, test_type: 'compile', test_block: 'New test code' } }
#         expect(response).to redirect_to(assignment_path(assignment))
#         follow_redirect!
#         expect(response.body).to include("Test was successfully created.")
#       end
#     end

#     context "with invalid parameters" do
#       it "does not create a test and shows error messages" do
#         post assignment_tests_path(assignment), params: { test: { name: '', points: 0, test_type: '', test_block: '' } }
#         expect(response).to redirect_to(assignment_path(assignment))
#         follow_redirect!
#         expect(response.body).to include("Missing attributes")
#       end
#     end
#   end

#   describe "GET /assignments/:assignment_id/tests/:id/edit" do
#     it "renders the edit form for the test" do
#       get edit_assignment_test_path(assignment, test_case)
#       expect(response).to have_http_status(:ok)
#     end
#   end

#   describe "PATCH /assignments/:assignment_id/tests/:id" do
#     context "with valid parameters" do
#       it "updates the test and redirects" do
#         patch assignment_test_path(assignment, test_case), params: { test: { name: 'Updated Test', points: 15, test_type: 'i/o', test_block: 'Updated code' } }
#         expect(response).to redirect_to(assignment_path(assignment, test_case))
#         follow_redirect!
#         expect(response.body).to include("Test was successfully updated.")
#         expect(test_case.reload.name).to eq('Updated Test')
#       end
#     end

#     context "with invalid parameters" do
#       it "does not update the test and shows error messages" do
#         patch assignment_test_path(assignment, test_case), params: { test: { name: '', points: 0, test_type: '', test_block: '' } }
#         expect(response).to redirect_to(assignment_path(assignment))
#         follow_redirect!
#         expect(response.body).to include("Missing attributes")
#       end
#     end
#   end

#   describe "DELETE /assignments/:assignment_id/tests/:id" do
#     it "deletes the test and redirects" do
#       delete assignment_test_path(assignment, test_case)
#       expect(response).to redirect_to(assignment_path(assignment))
#       follow_redirect!
#       expect(response.body).to include("Test was successfully destroyed.")
#       expect(assignment.tests.exists?(test_case.id)).to be_falsey
#     end
#   end
# end
