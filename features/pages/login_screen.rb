require 'calabash-cucumber/ibase'

class LoginScreen < Calabash::IBase

  def trait
    title
  end

  def title
    wait_for_none_animating
    "label marked:'Sign Up'"
  end

  def login_button
    keyboard_enter_char "Return"
  end

  def navigate
    await
  end

end
