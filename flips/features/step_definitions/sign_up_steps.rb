And /^I fill "(.*?)" field with the value -13 years old$/ do |field|
    touch "label text:'#{field}'"
    date_now = Time.new
    date_13 = date_now - (284880 * 60 * 24)
    birthday = date_13.strftime("%m%d%Y")
    keyboard_enter_text birthday
end

And /^I fill "Birthday" field with the value birthday tomorrow$/ do
  touch "label text:'#{field}'"
  date_now = Time.new
  date_13 = date_now - (284400 * 60 * 24)
  birthday = date_13.strftime("%m%d%Y")
  keyboard_enter_text birthday
end

And /^I fill "Birthday" field with the value today$/ do
  touch "label text:'#{field}'"
  date_now = Time.new
  birthday = date_now.strftime("%m%d%Y")
  keyboard_enter_text birthday
end

And /^I choose a photo$/ do
  touch @current_page.avatar_button
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

Then /^I should see a message "(.*?)"$/ do |message|
  check_element_exists ("label marked: '#{message}' isEnabled:1")
end

When /^There is no value in any field$/ do
end

And /^The cursor is in any field too$/ do
end
