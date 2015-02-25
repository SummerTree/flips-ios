require 'calabash-cucumber/ibase'

class ComposeScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "label marked:'New Flip'"
  end

  def compose_preview
    "button marked:'Preview'"
  end

  def navigate
    unless current_page?
      newflip_screen = go_to(NewFlipsScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch newflip_screen.newflip_compose
    end

    await
  end

end
