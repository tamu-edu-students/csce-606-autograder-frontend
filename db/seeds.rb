Test.destroy_all
TestGrouping.destroy_all
Assignment.destroy_all

# Create an assignment first
assignment = Assignment.create!(assignment_name: "Sample Assignment", repository_name: "sample_repo")


# Create additional test groupings associated with the assignment
group1 = TestGrouping.create!(name: "Basic Tests", assignment_id: assignment.id)
group2 = TestGrouping.create!(name: "Advanced Tests", assignment_id: assignment.id)

# Now create tests associated with test groupings
Test.create!(
  name: "Test 1",
  points: 10,
  test_type: "unit",
  test_grouping_id: group1.id,
  assignment_id: assignment.id,
  target: "Function A",
  include: "test_helper",
  position: 1,
  show_output: true,
  skip: false,
  timeout: 30,
  visibility: "visible",
  test_block: "assert_equal(...)"
)

Test.create!(
  name: "Test 2",
  points: 10,
  test_type: "unit",
  test_grouping_id: group2.id,
  assignment_id: assignment.id,
  target: "Function A",
  include: "test_helper",
  position: 2,
  show_output: true,
  skip: false,
  timeout: 30,
  visibility: "visible",
  test_block: "assert_equal(...)"
)
