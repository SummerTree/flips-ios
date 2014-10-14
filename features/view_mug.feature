Feature: View Mug screen
  As a user
  I want to see all my received mugs
  So, I can read my received mugs

@7444
Scenario: Touching a mug
  Given I am on the "Inbox" screen
  When I touch a mug message on the list
  Then I should see "View Mug" screen

@7444
Scenario: Watching an unread mug when I have read messages in the same mug
  Given I am on the "Inbox" screen
  When I touch a message mug on the list that has read and unread mugs
  Then I should see the oldest unread mug at the top of the screen
  And This mug video should starts to play automatically
  And I shouldn't see the all the words beneath the video

@7444
Scenario: Watching a message mug with only read mugs
  Given I am on the "Inbox" screen
  When I touch a message mug on the list that has only read mugs
  Then The video should start to play
  And I should see beneath the video the text sent to me on the video

@7444
Scenario: Watching a video mug
  Given I am on the "View Mug" screen
  And I am watching an unread video mug
  When The video finish
  Then I should see beneath the video the text sent to me on the video

@7445
Scenario: Scrolling a mug when it's playing
  Given I am on the "Inbox" screen
  And There is a conversation with unread messages
  When I touch this conversation
  And Before the video finished I scroll the screen to view new messages
  Then The video should stops
  And The text for the videos is not shown

@7445
Scenario: Scrolling a mug when there are 2 unread messages in sequence and the first mug is playing
  Given I am on the "Inbox" screen
  And There is a conversation with 2 unread messages in sequence
  When I touch this conversation
  And The mug is still playing and I scroll up
  Then The first mug should stop
  And The second one should start

@7445
Scenario: Scrolling a mug when there are 2 unread messages in sequence and the first mug finished
  Given I am on the "Inbox" screen
  And There is a conversation with 2 unread messages in sequence
  And I touch this conversation
  When The first message ends
  And I scroll up
  Then The second mug should starts

@7445
Scenario: Pause a video mug
  Given I am on the "Inbox" screen
  And I tap a conversation
  When I am watching a mug video
  And I touch the video
  Then The video mug should stops

@7445
Scenario: Un-Pause a video mug
  Given I am on the "Inbox" screen
  And I tap a conversation
  When I am watching a mug video
  And I touch the video
  And I touch again
  Then The video mug should starts where it left off

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

Scenario: Showing the time when the message was send from another country
  Given My friend sent a message to me from Brasil
  And In Brasil it's 10am
  When I go to "View Mug"
  And I watch the mug
  Then The time showed should be 6am

Scenario: Showing user message for the first time watching a message sent by MugBoys
  Given I am on the "View Mug" screen
  When I am watching MugBoys mug
  Then I should see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

Scenario: Showing user message for the first time watching a message didn't send by MugChat
  Given I am on the "View Mug" screen
  When I am watching a mug that was not sent by MugBoys
  Then I should not see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

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
