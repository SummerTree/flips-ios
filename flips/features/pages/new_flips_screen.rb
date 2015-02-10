require 'calabash-cucumber/ibase'

class NewFlipsScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "label marked:'New Flip'"
  end

  def newflip_compose
    "button marked:'Next'"  
  end

  def navigate
    unless current_page?
      inbox_screen = go_to(InboxScreen)
      sleep(STEP_PAUSE)
      wait_for_none_animating
      touch inbox_screen.inbox_compose
    end

    await
  end

end
