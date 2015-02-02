Feature: Onboarding screen
  As a user
  I want to know how to use this app
  So, I can see the onboarding information

#onboarding
Scenario: Showing a message on FlipBoys conversation
  Given I am on the "Microphone" screen
  When The selected message is FlipBoys
  Then I should see a message: "You can add audio to any photo. Give it a try. Tap & Hold to record audio"
  
#onboarding
Scenario: Showing a message on any conversation
  Given I am on the "Microphone" screen
  When The selected conversation is not FlipBoys
  Then I should not see a message: "You can add audio to any photo. Give it a try. Tap & Hold to record audio"


Scenario: Showing Message when is FlipBoys flips
  Given I am on the "Compose" screen
  When The flips selected is FlipBoys Flips
  Then I should see the message: "This is where the magic happens. Tap the + to record the first word."

Scenario: Showing Message when is not FlipBoys flips
  Given I am on the "Compose" screen
  When The Flip selected is not FlipBoys flips
  Then I shouldn't see the message: "This is where the magic happens. Tap the + to record the first word."


Scenario: Seeing FlipBoys message
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see "FlipBoys" conversation

Scenario: Visualizing Inbox screen for the first time
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see a purple ballon with the message: "Welcome to Flips You have a message. Must be nice to be so popular."

Scenario: Showing user message for the first time watching a message sent by FlipBoys
  Given I am on the "View Flips" screen
  When I am watching FlipBoys message
  Then I should see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

Scenario: Showing user message for the first time watching a message didn't send by Flips
  Given I am on the "View Flips" screen
  When I am watching a flips that was not sent by FlipBoys
  Then I should not see a purple ballon with the message: Pretty cool, huh? Now it's your turn.
