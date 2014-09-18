Feature: Controller of MugChat
  As a user
  I want to do some not commons things
  So, I want to have a nice feedback from the app

Scenario: Migration to another device
  Given I set up my number on my iphone
  And I have a lot of friends and mugs
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

#Ben, is there a time to receive the message? Like I'm 3 days without connect on internet, so, if I connect now, the mug was gone!  
Scenario: Sending a Mug to a offline contact
  Given I am on the "New Mug" screen
  When I pick up a offline contact
  And I send a mug to him/her
  Then I should receive any message
  And The contact should receive the message when he/she conects on the internet
