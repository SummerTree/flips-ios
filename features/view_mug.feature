Feature: View Flips screen
  As a user
  I want to see all my received flips
  So, I can read my received flips

@7444 @ok
Scenario: Touching a conversation on the list
  Given I am on the "Inbox" screen
  When I touch a conversation on the list
  Then I should see "View Flips" screen

@7444 @Nok
Scenario: Watching an unread flips when I have read messages in the same conversation
  Given I am on the "Inbox" screen
  When I touch a conversation on the list that has read and unread flips
  Then I should see the oldest unread flips at the top of the screen
  And This flips video should starts to play automatically
  And I shouldn't see the all the words beneath the video

@7444 @Nok
Scenario: Watching a conversation with only read flips
  Given I am on the "Inbox" screen
  When I touch a conversation on the list that has only read flips
  Then The video for the newest message should start to play
  And I should see beneath the video the text sent to me on the video

@7444 @Nok
Scenario: Watching a video
  Given I am on the "View Flips" screen
  And I am watching an unread video
  When The video finish
  Then I should see beneath the video the text sent to me on the video

@7445 @ok
Scenario: Scrolling a conversation when the video is playing
  Given I am on the "Inbox" screen
  And There is a conversation with unread messages
  When I touch this conversation
  And Before the video finished I scroll the screen to view new messages
  Then The video should stops
  And The text for the videos is not shown

@7445
Scenario: Scrolling a conversation when there are 2 unread messages in sequence and the first flips is playing
  Given I am on the "Inbox" screen
  And There is a conversation with 2 unread messages in sequence
  When I touch this conversation
  And The video is still playing and I scroll up
  Then The first flips should stop
  And The second one should start

@7445 @Nok
Scenario: Scrolling a conversation when there are 2 unread messages in sequence and the first flips finished
  Given I am on the "Inbox" screen
  And There is a conversation with 2 unread messages in sequence
  And I touch the first conversation
  When The first message ends
  And I scroll up
  Then The second flips should starts

@7445 @ok
Scenario: Pause a video
  Given I am on the "Inbox" screen
  And I tap a conversation
  When I am watching a flips video
  And I touch the video
  Then The video flips should stops

@7445 @ok
Scenario: Un-Pause a video flips
  Given I am on the "Inbox" screen
  And I tap a conversation
  When I am watching a flips video
  And I touch the video
  And The video stops
  And I touch it again
  Then The video should starts where it left off


Scenario: Watching a flips in a group
  Given I am on the "View Flips" screen
  When The conversation has more than one person
  Then I should see "People list" icon

Scenario: Touching People list option
  Given I am on the "View Flips" screen
  And The conversation has more than one person
  When I touch "People list" option
  Then I should see all people in this group

Scenario: Dismiss people list
  Given I am seeing "People list" list
  When I touch "People list" icon
  Then I shouldn't see "People list" list

@ok
Scenario: Time for each word with video
  Given I am on the "View Flips" screen
  When I am watching a flips video that has more than one word
  Then I should see each word and video for 1 seconds

@ok
Scenario: Time for each word with picture
  Given I am on the "View Flips" screen
  When I am watching a flips video that has more than one photo
  Then I should see each word and photo for 1 seconds

@ok
Scenario: Time for each word with picture and voice
  Given I am on the "View Flips" screen
  When I am watching a flips video that has more than one photo with voice recorded
  Then I should see each word and photo with voice for 1 seconds

@ok
Scenario: Showing the time when the message was send from another country
  Given My friend sent a message to me from Brasil
  And In Brasil it's 10am
  And I am in San Francisco
  When I go to "View Flips"
  And I watch the flips
  Then The time showed should be 6am

@ok
Scenario: Touching Back button
  Given I am on the "View Flips" screen
  When I touch "Back" button
  Then I should see "Inbox" screen

@ok
Scenario: Verifying title screen when the conversation has only one person
  Given I am on the "View Flips" screen
  When I have a conversation with only one person
  Then I should see person's name who send me the message as a title

Scenario: Verifying title screen when the conversation has more than one person
  Given I am on the "View Flips" screen
  When I have a conversation with only more than one person
  Then I should see "Group Chat" as a title

@ok
Scenario: Verifying design screen
  Given I am on the "View Flips" screen
  Then The desing screen should be the same on the prototype design
