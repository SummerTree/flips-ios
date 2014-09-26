Feature: Controller of MugChat
  As a user
  I want to do some not commons things
  So, I want to have a nice feedback from the app

@7087
Scenario: Receiving a notification when the app is open but in background
  Given The app is open in back ground
  When I receive a mug message
  Then I should see the native notification from device with the message: "You received a new mug message from <user/friend>. Swipe or tap to view."

@7087
Scenario: Receiving a notification when mugchat is open
  Given I am using the app
  When I receive a mug message
  Then I shouldn't see a native notification from device
#Ben will verify if should or not see a notification


Scenario: Migration to another device
  Given I set up my number on my iphone
  And I have a lot of friends and mugs message
  When I put the same number in another device
  Then I should see my friends and mugs in both devices

Scenario: Receiving a mug when I have 2 devices with the same number
  Given I have 2 devices with the same number
  When I receive a mug
  Then I should receive in both devices

Scenario: Sending a mug when I have the same number in 2 devices
  Given I have 2 devices with the same number
  When I send a mug from one device
  Then My friend should receive my mug
  And My other device should have the log of this mug

Scenario: Sending a mug to a user
  Given I am on the "Inbox" screen
  When I send a mug to a specific user
  Then Just this user should receive the mug
  And the other friends should not receive the mug

Scenario: Reply a message to more than one person
  Given I am on the "View Mug" screen
  And I am view a mug that there is more than one person
  When I reply a message in this mug
  Then All people in this mug should receive my mug reply

Scenario: Sending a Mug to a offline contact
  Given I am on the "New Mug" screen
  When I pick up a offline contact
  And I send a mug to him/her
  Then I should receive any message
  And The contact should receive the message when he/she conects on the internet

Scenario: Receiving a mug message after 31 days offline
  Given A friend sent me a mug message
  And I am offline for 31 days
  When I connect the internet and be online again
  Then I shouldn't receive the message

Scenario: Receiving a mug message after 30 days offline
  Given A friend sent me a mug message
  And I am offline for 30 days
  When I connect the internet and be online again
  Then I should receive the message
