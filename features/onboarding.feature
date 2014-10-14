#onboarding
Scenario: Showing a message on MugBoys conversation
  Given I am on the "Microphone" screen
  When The selected message is MugBoys
  Then I should see a message: "You can add audio to any photo. Give it a try. Tap & Hold to record audio"
#onboarding
Scenario: Showing a message on any conversation
  Given I am on the "Microphone" screen
  When The selected conversation is not MugBoys
  Then I should not see a message: "You can add audio to any photo. Give it a try. Tap & Hold to record audio"


Scenario: Showing Message when is MugBoys mug
  Given I am on the "Compose" screen
  When The mug selected is MugBoys mug
  Then I should see the message: "This is where the magic happens. Tap the + to record the first word."

Scenario: Showing Message when is not MugBoys mug
  Given I am on the "Compose" screen
  When The mug selected is not MugBoys mug
  Then I shouldn't see the message: "This is where the magic happens. Tap the + to record the first word."


Scenario: Seeing MugBoys message
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see "MugBoys" conversation

Scenario: Visualizing Inbox screen for the first time
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see a purple ballon with the message: "Welcome to MugChat You have a message. Must be nice to be so popular."
