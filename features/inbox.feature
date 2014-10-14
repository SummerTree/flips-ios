Feature: Inbox screen
  As a user
  I want to have a organizated list
  So I can see all of my messages

@7171
Scenario: Access Inbox screen by login screen
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mug@mail.com"
  And I fill "Password" with the value: "Mugchat1"
  And I touch "Done" button
  Then I should see "Inbox" screen

@7172
Scenario: Access Inbox screen by New password screen
  Given I am on the "New Password" screen
  When I fill "New Password" whit "MugTest1"
  And I touch "Done" button
  Then I should see "Inbox" screen

Scenario: Seeing MugBoys message
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see "MugBoys" conversation

Scenario: Visualizing Inbox screen for the first time
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see a purple ballon with the message: "Welcome to MugChat You have a message. Must be nice to be so popular."

@7223
Scenario: Having one or more messages unread
  Given I am on the "Inbox" screen
  When I have one or more messages unread
  Then I should see a badge over avatar with the total unread messages

@7223
Scenario: Having read and unread messages
  Given I am on the "Inbox" screen
  When I have read and unread messages sent by the same person in the same conversation
  Then I should see just one item on the list
  And I should see a badge over avatar with the total unread messages

@7223
Scenario: Person's photo when the message has more than one person and read and unread messages
  Given I am on the "Inbox" screen
  And I have a message with more than one person
  When I have read and unread messages sent by diferent people in the same conversation
  Then I should see the person's photo from the guy who sent the oldest unread message

@7223
Scenario: Person's photo when the message has more than one person and only read messages
  Given I am on the "Inbox" screen
  And I have a message with more than one person
  When I have only read messages sent by diferent people in the same conversation
  Then I should see the person's photo from the last guy who sent message

@7223
Scenario: Person's photo when I have a conversation with just one person
  Given I am on the "Inbox" screen
  And I have a message with just a person
  When I have unread or read messages
  Then I should see person's photo

@7223
Scenario: Background's photo when the conversation has more than one person and read and unread messages
  Given I am on the "Inbox" screen
  And I have a message with more than one person
  When I have read and unread messages sent by diferent people in the same conversation
  Then I should see the first frame of the video of the oldest unread message as background

@7223
Scenario: Background's photo when the conversation has more than one person and only read messages
  Given I am on the "Inbox" screen
  And I have a message with more than one person
  When I have only read messages sent by diferent people in the same conversation
  Then I should see the first frame of the video of the most recent message mug sent to me as background

@7223
Scenario: Sending a conversation to a person from another country
  Given I am on "Brasil"
  And It's 10am
  When I send a mug to "EUA"
  Then The time showed on "Inbox" screen should be 6am

@7223
Scenario: Time when I have read and unread messages
  Given I am on the "Inbox" screen
  When I have read and unread messages in the same conversation
  Then I should see the time for the oldest message was sent to me

@7223
Scenario: Time when I have only read messages
  Given I am on the "Inbox" screen
  When I have only read messages in the same conversation
  Then I should see the time for the most recent message was sent to me

@7223
Scenario: Text on the bottom of the mug when I have read and unread messages
  Given I am on the "Inbox" screen
  When I have a conversation on the list that has unread messages
  Then I should see the text: "Tap to Play" on the bottom of the mug

@7223
Scenario: Text on the bottom of the mug when I have just read messages
  Given I am on the "Inbox" screen
  When I have a conversation on the list that has just read messages
  Then I should see the beginning of most recently message read on the bottom of the mug

@7225
Scenario: Swiping a conversation
  Given I am on the "Inbox" screen
  When I swipe left a conversation on the list
  Then I should "Delete" icon

@7225
Scenario: Deleting a conversation
  Given I am seeing "Delete" icon
  When I drop the conversation
  Then the conversation should not be showed on the list
  But my friend's inbox should still show this conversation

@7225
Scenario: Deleting all my conversations
  Given I am on the "Inbox" screen
  When I delete all my conversations
  Then I shouldn't see my conversations
  And I can't to delete MugBoys conversation

@7223
Scenario: Receiving a new conversation
  Given I am on the "Inbox" screen
  And I have Mugs on my list
  When I receive a new mug
  Then It should be on the top of the list
  And The other mugs should be sorted by time stamp descending order

@7223
Scenario: So much conversations on my list
  Given I am on the "Inbox" screen
  And I have a lot of conversations
  When I have no space to so much conversations
  Then A scroll bar should be showed

Scenario: Touching Construction icon
  Given I am on the "Inbox" screen
  When I touch the "Construction" icon
  Then I should see "Builder" screen

@7223
Scenario: Verifying design screen
  Given I am on the "Inbox" screen
  Then The desing screen should be the same on the prototype design
