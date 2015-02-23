Feature: Controller of Flips
  As a user
  I want to do some not common things
  So, I want to have a nice feedback from the app

@7087 @Ok
Scenario: Receiving a notification when the app is open but in background
  Given The app is open in back ground
  When I receive a flips message
  Then I should see the native notification from device with the message: "You received a new flips message from <user/friend>. Swipe or tap to view."

@7087 @Nok
Scenario: Touching notification
  Given I received a notification
  When I touch on the notification
  Then I should see "View Flips" screen
  And The flips message sent to me should start to play

@7087 @Ok
Scenario: Receiving a notification when flips is open
  Given I am using the app
  When I receive a flips message
  Then I shouldn't see a native notification from device


Scenario: Flips message so big that I can receive all message
  Given I am on the "Inbox" screen
  And I received a really big flips message
  And My internet is very slow
  When I touch flips message
  And The message should download for complete
  Then I should see a option the start download again

Scenario: Migration to another device
  Given I set up my number on my iphone
  And I have a lot of friends and flips message
  When I put the same number in another device
  Then I should see my friends and flips in both devices

Scenario: Receiving a flips message when I have 2 devices with the same number
  Given I have 2 devices with the same number
  When I receive a flips message
  Then I should receive in both devices

Scenario: Sending a flips message when I have the same number in 2 devices
  Given I have 2 devices with the same number
  When I send a flips message from one device
  Then My friend should receive my flips
  And My other device should have the log of this flips

Scenario: Sending a flips to a user
  Given I am on the "Inbox" screen
  When I send a flips to a specific user
  Then Just this user should receive the flips
  And the other friends should not receive the flips

Scenario: Reply a message to more than one person
  Given I am on the "View Flips" screen
  And I am view a flips that there is more than one person
  When I reply a message in this flips
  Then All people in this flips should receive my flips reply

Scenario: Creating a Flips message when I am offline
  Given I am offline
  When I touch "Pencil" button
  Then I should create a new flips

Scenario: Sending a Flips message when I am offline
  Given I am offline
  And I have a flips message created
  When I go to "Preview" screen
  And I touch "V" button
  Then I should see my flips message on the "View Flips" screen

Scenario: Receiving a flips message when it was send when I was offline
  Given I sent a message when I was offline
  When I am online
  Then My friends should receive my flips message

Scenario: Sending a Flips to a offline contact
  Given I am on the "New Flips" screen
  When I pick up a offline contact
  And I send a flips to him/her
  Then I should receive any message
  And The contact should receive the message when he/she conects on the internet

Scenario: Receiving a flips message after 31 days offline
  Given A friend sent me a flips message
  And I am offline for 31 days
  When I connect the internet and be online again
  Then I shouldn't receive the message

Scenario: Receiving a flips message after 30 days offline
  Given A friend sent me a flips message
  And I am offline for 30 days
  When I connect the internet and be online again
  Then I should receive the message
