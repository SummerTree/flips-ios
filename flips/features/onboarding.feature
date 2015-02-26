Feature: Onboarding screen
  As a user
  I want to know how to use this app
  So, I can see the onboarding information

@Flips-199
Scenario: Creating a new user
  Given I don't have a Flips account
  And I'm registering my user on "Sign Up" screen
  And I fill all fields with valid values
  And I go to "Verification Code" screen
  When I fill with a valid verification code
  Then I should see "Inbox" screen
  And I should see "Flip Boys" message

@Flips-199
Scenario: Changing Flip Boys message and registering a new user
  Given I changed the pictures and text of "Flip Boys" message
  When I register a new user
  Then I should see this new message on my "Inbox" screen

@Flips-199
Scenario: Changing Flip Boys message when I already have a user registered
  Given I have a user already registered
  When I change the flip boys message
  Then I shouldn't receive this new message
  And I should keep seeing the old "Flip Boys" message on the "Inbox" screen

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
