require 'calabash-cucumber/ibase'

class PreviewScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "button marked:'Send'"
  end

  def navigate
    unless current_page?
      compose_screen = go_to(ComposeScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch compose_screen.compose_preview
    end

    await
  end

end
