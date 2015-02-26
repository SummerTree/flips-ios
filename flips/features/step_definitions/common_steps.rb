Given /^I am on the "(.*?)" screen$/ do |screen_name|
  @current_page = page_by_name(screen_name)
  @current_page.navigate

  sleep(STEP_PAUSE)
end

When /^I fill "(.*?)" field with the value "(.*?)"$/ do |field, value|
  touch "label text:'#{field}'"
  keyboard_enter_text value
end

Then /^I should see "(.*?)" screen$/ do |screen|
  required_page = page_by_name(screen)
  wait_for { required_page.current_page? }
  @current_page = required_page
  sleep(STEP_PAUSE)
end

When /^I touch "(.*?)" option$/ do |option|
  option = query "button marked: '#{option}'"
  touch option
end

When /^I touch "(.*?)" button$/ do |button|
  button_name = query "button marked:'#{button}'"
  touch button_name
end

Then /^I should see "(.*?)" button disabled$/ do |button|
  check_element_exists ("button marked:'Forward' isEnabled:0")
end

And /^I exit the field$/ do
  miss_keyboard
end

Then /^I should see "(.*?)" keyboard$/ do |type|
  field = query("view isFirstResponder:1", :keyboardType).first
  puts field

  types = KEYBOARD_TYPES[:Alpha]
  puts types
  puts type
  if field == types
    raise "keyboard type Ok"
  end
end

When /^I touch "(.*?)" field$/ do |field|
  touch "label text:'#{field}'"
end
