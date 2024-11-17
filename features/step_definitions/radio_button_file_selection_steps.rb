When("We click on {string}") do |link|
    case link
    when "include"
      find('#include-file-dropdown').click
      expect(page).to have_css('#include-file-tree-dropdown', visible: true, wait: 5)
    when "compile"
      find('#test_block_compile_paths').click
      expect(page).to have_css('#compile-file-tree-dropdown', visible: true, wait: 5)
    when "source_paths"
      find('#test_block_source_paths').click
      expect(page).to have_css('#source-path-file-tree-dropdown', visible: true, wait: 5)
    when "memory_errors"
      find('#test_block_mem_error_paths').click
      expect(page).to have_css('#mem-error-file-tree-dropdown', visible: true, wait: 5)
    when "main_path"
      find('#test_block_main_path').click
      expect(page).to have_css('#main-path-file-tree-dropdown', visible: true, wait: 5)
    when "input_path"
      find('#test_block_input_path').click
      expect(page).to have_css('#input-file-tree-dropdown', visible: true, wait: 5)
    when "output_path"
      find('#test_block_output_path').click
      expect(page).to have_css('#output-file-tree-dropdown', visible: true, wait: 5)
    else
      click_link link
    end
end

  
Then("I should see a {string} beside each file name") do |selector|
    within(".dropdown-content") do
      if selector == "checkbox"
        expect(page).to have_css("input[type='checkbox'].file-checkbox", count: all(".file-item").size)
      elsif selector == "radio_button"
        expect(page).to have_css("input[type='radio'].file-radio", count: all(".file-item").size)
      else
        raise "Invalid selector: #{selector}. Expected 'checkbox' or 'radio_button'."
      end
    end
  end
  