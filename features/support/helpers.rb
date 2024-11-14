def fill_test_block(test_type)
    case test_type
    when 'approved_includes'
      fill_in 'Enter Approved Includes', with: 'file1'
      click_button "Add Approved Includes"
      fill_in 'Enter Approved Includes', with: 'file2', match: :first
    when 'compile'
      steps %(
        And I click on "compile"
        And I expand the "io_tests" directory
        And I select the following files in "compile" dropdown:
          | Directory             | File           |
          | tests/c++/io_tests    | input.txt      |
          | tests/c++/io_tests    | output.txt     |
          | tests/c++/io_tests    | readme.txt     |
      )
    when 'coverage'
      steps %(
        And I click on "source-paths"
        And I expand the "io_tests" directory
        And I select the following files in "source-paths" dropdown:
          | Directory             | File           |
          | tests/c++/io_tests    | input.txt      |
          | tests/c++/io_tests    | output.txt     |
          | tests/c++/io_tests    | readme.txt     |
      )
    when 'performance'
      fill_in 'Enter Performance', with: 'EXPECT_EQ(1, 1);'
    when 'unit'
      fill_in 'Enter Unit', with: 'EXPECT_EQ(1, 1);'
    when 'i_o'
      fill_in 'Enter Input Path', with: 'input'
      fill_in 'Enter Output Path', with: 'output'
    when 'memory_errors'
      steps %(
        And I click on "memory_errors"
        And I expand the "io_tests" directory
        And I select the following files in "memory_errors" dropdown:
          | Directory             | File           |
          | tests/c++/io_tests    | input.txt      |
          | tests/c++/io_tests    | output.txt     |
          | tests/c++/io_tests    | readme.txt     |
      )
    when 'script'
      fill_in 'Enter Script Path', with: 'script'
    else
      raise "Unknown test type: #{test_type}"
    end
end

def check_test_block(type)
  # # can see the right partial rendered in the bottom
  # if "Test Type" dropdown is unselected, select type
  unless page.has_select?('Test Type', selected: type, visible: true)
    Capybara.using_wait_time(10) do
      select type, from: 'Test Type'
    end
  end
  expect(page).to have_select('Test Type', selected: type)
  case type
  when 'approved_includes'
    # puts 'type appinclu'
    within('#approved-includes-container', wait: 10) do
      expect(page).to have_selector("input[name='test[test_block][approved_includes][]']", visible: true)
    end
    #expect(page).to have_button("Add Approved Includes")
  when 'compile'
    within('#compile-file-container', wait: 10) do
      expect(page).to have_selector("input[name='test[test_block][file_paths][]']", visible: true)
    end
    #expect(page).to have_button("Add Compile Path")
  when 'memory_errors'
    within('#memory-errors-container', wait: 10) do
      expect(page).to have_selector("input[name='test[test_block][file_paths][]']", visible: true)
    end
    #expect(page).to have_button("Add Memory Errors Path")
  when 'i_o'
    expect(page).to have_selector("input[name='test[test_block][input_path]']", visible: true, wait: 10)
    expect(page).to have_selector("input[name='test[test_block][output_path]']", visible: true)
  when 'coverage'
    expect(page).to have_selector("input[name='test[test_block][main_path]']", visible: true, wait: 10)
    within('#source-paths-container') do
      expect(page).to have_selector("input[name='test[test_block][source_paths][]']", visible: true)
    end
    #expect(page).to have_button("Add Source Path")
  when 'performance'
    expect(page).to have_selector("textarea[name='test[test_block][code]']", visible: true, wait: 10)
  when 'unit'
    expect(page).to have_selector("textarea[name='test[test_block][code]']", visible: true, wait: 10)
  when 'script'
    expect(page).to have_selector("input[name='test[test_block][script_path]']", visible: true, wait: 10)
  else
    raise "Unknown test type: #{type}"
  end
end
