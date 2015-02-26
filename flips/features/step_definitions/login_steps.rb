When /^I fill Email field with the value "(.*?)"$/ do |value|
  email=query("UITextField")[1]
  clear_text("UITextField")[1]
  touch email
  keyboard_enter_text value
  sleep(STEP_PAUSE)
end

And /^I touch Done button$/ do
  keyboard_enter_char "Return"
end
