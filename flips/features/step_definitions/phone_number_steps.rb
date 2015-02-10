When /^I type a valid phone number$/ do
    phone_field = query "* text: 'Mobile Number'"
    touch phone_field
    phone_random = 1000000000 + rand(8999999999)
    keyboard_enter_text phone_random
    wait_none_animating
end
