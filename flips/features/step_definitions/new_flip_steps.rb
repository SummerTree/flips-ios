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
