require 'rspec/mocks'

  Then('primary navigation elements should be links styled as buttons with clear labels') do
    expect(page).to have_selector('a.btn') # This will check for elements with the class "btn"
    
    page.all('.btn').each do |button|
      expect(button[:value].present? || button.text.present?).to be true
    end
  end