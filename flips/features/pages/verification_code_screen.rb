require 'calabash-cucumber/ibase'

class VerificationCodeScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "* text:'Verification Code'"
  end

  def navigate
    unless current_page?
      phonenumber_screen = go_to(PhoneNumberScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch phonenumber_screen.verification_code
    end

    await
  end

end
