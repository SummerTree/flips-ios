Feature: Notification
  As a user
  I want to know when my friends send me a flips message
  So, I want to receive a notification

@Flips-247
Scenario: Receiving a notification when the app is open but in background
  Given The app is open in back ground
  When I receive a flips message
  Then I should see a notification with the message: "You received a new Flip message from <user/friend>."

@Flips-247
Scenario: Receiving a notification when I'm logged in on the app but the app is closed
  Given I am logged in on the Flips
  But The flips are closed
  When I receive a flips message
  Then I should see a notification with the message: "You received a new Flip message from <user/friend>."

@Flips-247
Scenario: Receiving a notification when I'm logged in on the app but my cellphone is off
  Given I am logged in on the Flips
  But My cellphone is off
  When I receive a message
  And I turn on my cellphone
  Then I should see a notification with the message: "You received a new Flip message from <user/friend>."

@Flips-247
Scenario: Touching notification
  Given I received a notification
  When I touch on the notification
  Then I should see "Thread View" screen
  And The flips message sent to me should start to play

@Flips-247
Scenario: Receiving a notification when flips is open
  Given I am with flips app open
  When I receive a flips message
  Then I shouldn't receive a notification

@Flips-247
Scenario: Receiving a notification when I logged out
  Given I am logged in on flips
  When I log off
  And I receive a message
  Then I shouldn't receive a notification
