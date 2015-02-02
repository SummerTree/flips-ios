require 'calabash-cucumber/ibase'

class DownloadScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "label marked:'Welcome Back'"
  end

  def navigate
    unless current_page?
      landing_screen = go_to(LoginScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch login_screen.login_button
    end

    await
  end

end
