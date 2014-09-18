Feature: View Mug screen
  As a user
  I want to see all my received mugs
  So, I can read my received mugs


Scenario: Touching a mug
  Given I am on the "Inbox" screen
  When I touch a mug on the list
  Then I should see "View Mug" screen

Scenario: Watching an unread mug
  Given I am on the "Inbox" screen
  When I touch an unread mug on the list
  Then The mug video should start to play
  And I shouldn't see the all the words

#Ben, is it right?
Scenario: Watching a read mug
  Given I am on the "Inbox" screen
  When I touch a read mug on the list
  Then The video shouldn't start to play
  And I should see the message sent to me

#Ben, is it right?
Scenario: Watching a mug when there is a read and an unread message
  Given I am on the "Inbox" screen
  When I touch a mug that has a read and an unread message
  Then The mug video for the unread message should start

Scenario: Watching a mug when there is two or more unread messages sent by different people
  Given I am on the "Inbox" screen
  When I touch a mug that has more than 2 unread messages
  Then I should see the first unread message sent to me
  And At the end of this message I should see the other oldest unread message sent to me
  And The photo's person should change according to the message being viewed
  And The time should change according to the message being viewed too

Scenario: Watching a mug in a group
  Given I am on the "View Mug" screen
  When The mug has more than one person
  Then I should see "People list" icon

Scenario: Touching People list option
  Given I am on the "View Mug" screen
  And The mug has more than one person
  When I touch "People list" option
  Then I should see all people in this group

Scenario: Miss people list
  Given I am seeing "People list" list
  When I touch "People list" icon
  Then I shouldn't see "People list" list

Scenario: Showing words after the mug video
  Given I am watching a mug video
  When The mug video finished
  Then I should see all words below the video

Scenario: Time for each word with video
  Given I am on the "View Mug" screen
  When I am watching a mug video that has more than one word
  Then I should see each word and video for 1 seconds

Scenario: Time for each word with picture
  Given I am on the "View Mug" screen
  When I am watching a mug video that has more than one photo
  Then I should see each word and photo for 1 seconds

Scenario: Time for each word with picture and voice
  Given I am on the "View Mug" screen
  When I am watching a mug video that has more than one photo with voice recorded
  Then I should see each word and photo with voice for 1 seconds

Scenario: Touching Reply button
  Given I am on the "View Mug" screen
  When I touch "Reply" icon
  Then I should see a text field
  And I should see "Next" button disable

Scenario: Writing a message to reply
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write a character
  Then I should see "Next" button enable

#waiting for Ben
Scenario: Writing a message with a lot of characters
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write ?? characters
  And I touch "Next" button
  Then ???

#waiting for Ben
Scenario: Writing a message and I don't have memory
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write some words
  And My cellphone's memory finish
  Then ???

Scenario: Showing the time when the message was send from another country
  Given My friend sent a message to me from Brasil
  And In Brasil it's 10am
  When I go to "View Mug"
  And I watch the mug
  Then The time showed should be 6am

#Ben, the purple ballon will be showed on MugBoys mug or only the first time in anyone mug?
Scenario: Showing user message for the first time watching a message sent by MugBoys
  Given I am on the "View Mug" screen
  When I am watching MugBoys mug
  Then I should see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

#Ben, the purple ballon will be showed on MugBoys mug or only the first time in anyone mug?
Scenario: Showing user message for the first time watching a message didn't send by MugChat
  Given I am on the "View Mug" screen
  When I am watching MugBoys mug
  Then I should see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

Scenario: Touching Back button
  Given I am on the "View Mug" screen
  When I touch "Back" button
  Then I should see "Inbox" screen

Scenario: Verifying title screen when the mug has only one person
  Given I am on the "View Mug" screen
  When I have a mug with only one person
  Then I should see person's name who send me the mug as a title

Scenario: Verifying title screen when the mug has more than one person
  Given I am on the "View Mug" screen
  When I have a mug with only more than one person
  Then I should see "Group Chat" as a title

Scenario: Verifying design screen
  Given I am on the "View Mug" screen
  Then The desing screen should be the same on the prototype design
