Given /^I am on the "(.*?)" screen$/ do |screen_name|
  @current_page = page_by_name(screen_name)
  @current_page.navigate

  sleep(STEP_PAUSE)
end

When /^I fill Email field with the value "(.*?)"$/ do |value|
  email=query("UITextField")[1]
  clear_text("UITextField")[1]
  touch email
  keyboard_enter_text value
  sleep(STEP_PAUSE)
end

When /^I fill "(.*?)" field with the value "(.*?)"$/ do |field, value|
  touch "label text:'#{field}'"
  puts field
  keyboard_enter_text value
end

And /^I fill "(.*?)" field with the value -13 years old$/ do |field|
  touch "label text:'#{field}'"
  puts field
  date_now = Time.new
  date_13 = date_now - (284880 * 60 * 24)
  birthday = date_13.strftime("%m%d%Y")
  keyboard_enter_text birthday
end

And /^I touch Done button$/ do
  keyboard_enter_char "Return"
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

And /^I have contact selected$/ do
  contact = query("UIImageView")[0]
  touch contact
  wait_for_keyboard()
  keyboard_enter_text "Maiana Alebrant"
end

And /^a message is typped$/ do
  message = query("UITextView")
  touch message
  wait_for_keyboard()
  keyboard_enter_text "Hi Maiana!"
end

Then /^I should see "(.*?)" button disabled$/ do |button|
  check_element_exists ("button marked:'Forward' isEnabled:0")
end

And /^I choose a photo$/ do
  avatar = query("button marked: 'AddProfilePhoto'")
  touch avatar
  sleep(STEP_PAUSE)
  button_ok = query("label marked: 'OK'")
  touch button_ok
  photo_button = query("* index:31")
  touch photo_button
  wait_for_none_animating
  sleep(STEP_PAUSE)
  camera_roll = query "label marked: 'Camera Roll'"
  touch camera_roll
  wait_for_none_animating
  sleep(STEP_PAUSE)
  photo = query "* index:10"
  touch photo
  wait_for_none_animating
  sleep(STEP_PAUSE)
  confirm = query "* id:'Approve'"
  touch confirm
  wait_for_none_animating
  sleep(STEP_PAUSE)
end

And /^I do not choose a photo$/ do
end

Then /^I should see a message: "Looks like your photo is missing!"$/ do
  message = query "label marked: 'Camera Roll'"
end
