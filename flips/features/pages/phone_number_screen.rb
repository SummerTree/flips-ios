require 'calabash-cucumber/ibase'

class PhoneNumberScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "* text:'Phone Number'"
  end

  def verification_code
    "* text:'Verification Code'"
  end

  def navigate
    unless current_page?
      signup_screen = go_to(SignUpScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch signup_screen.signup_phone
    end

    await
  end

end
