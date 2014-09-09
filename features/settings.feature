Feature: Settings screen
  As an user
  I wanto to set up some informations
  So, I can access Settings screen

Scenario: Access Settings Screen
  Given I am on the "Onboarding" screen
  When I touch "Gear" button
  Then I should see "Settings" screen

Scenario: Access About Screen
  Given I am on the "Settings" screen
  When I touch "About" option
  Then I should see "About" screen

Scenario: Touching Back on About screen
  Given I am on the "About" screen
  When I touch "Back" button
  Then I should see "Settings" screen

Scenario: Access Send FeedBack screen
  Given I am on the "Settings" scren
  When I touch "Send FeedBack" option
  Then I should see "Send FeedBack" screen

Scenario: Touching Log Out option
  Given I am on the "Settings" scren
  When I touch "Log Out" option
  Then I should see "Splash" screen

Scenario: Touching X button
  Given I am on the "Settings" screen
  When I touch "X" button
  Then I should see "Onboarding" screen
