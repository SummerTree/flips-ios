require 'calabash-cucumber/ibase'

class SignUpScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "label marked:'First Name'"
  end

  def birthday= date
    touch "label text:'Birthday'"
    keyboard_enter_text date
  end

  def signup_phone
    "label marked:'Mobile Number'"
  end

  def avatar_button
    "button marked: 'AddProfilePhoto'"
  end


  def navigate
    unless current_page?
      login_screen = go_to(LoginScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch login_screen.login_signup
    end

    await
  end

end
