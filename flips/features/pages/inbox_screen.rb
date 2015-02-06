require 'calabash-cucumber/ibase'

class InboxScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "button marked:'Compose'"
  end

  def inbox_settings
    "button marked:'Settings'"
  end

  def inbox_compose
    "button marked:'Compose'"
  end

  def navigate
    unless current_page?
      login_screen = go_to(LoginScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch login_screen.login_button
    end

    await
  end

end
