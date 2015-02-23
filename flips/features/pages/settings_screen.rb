require 'calabash-cucumber/ibase'

class SettingsScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "button marked:'Log Out'"
  end

  def navigate
    unless current_page?
      inbox_screen = go_to(InboxScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch inbox_screen.inbox_settings
    end

    await
  end

end
