Feature: Inbox screen
  As a user
  I want to have a organizated list
  So I can see all of my messages

@7171 @ok @automated @Flips-145 @Flips-148
Scenario: Access Inbox screen by login screen
  Given I am on the "Login" screen
  When I fill Email field with the value "maiana.momm3@arctouch.com"
  And I fill "Password" field with the value "Password1"
  And I touch Done button
  Then I should see "Inbox" screen

@7223 @ok @Flips-148
Scenario: Badge Counting#break this scenario
  Given I am on the "Inbox" screen
  And I have a conversation with messages
  When I have messages: read, unread(sent by different people and the same people) and messages sent by me on this conversation
  Then I should see a badge over avatar with the total unread messages

@7223 @Flips-148
Scenario: Seeing avatar when I have just read messages and the last one is not mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message wasn't sent by me
  Then I should see the user's photo of the last received message of my conversation as an avatar

@7223 @Flips-148
Scenario: Seeing avatar when I have just read messages and the last one is mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message was sent by me
  Then I should see my photo as an avatar

@7223 @Flips-148
Scenario: Seeing avatar when the last message is read but I have some unread messages on the same conversation
  Given I am on the "Inbox" screen
  When I have a conversation where my last message is read
  But I have one unread messages on it
  Then I should see the user's photo of this unread message as an avatar

@7223 @Flips-148
Scenario: Seeing avatar when I have more than one unread message on the conversation
  Given I am on the "Inbox" screen
  When I have more than one unread message on the same conversation
  Then I should see the user's photo of the oldest unread message as an avatar

@7223 @Flips-148
Scenario: Seeing Preview Photo when I have just read messages and the last one is not mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message wasn't sent by me
  Then I should see the first fram of the last message of my conversation as preview photo

@7223 @Flips-148
Scenario: Seeing Preview Photo when I have just read messages and the last one is mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message was sent by me
  Then I should see the first frame of the message that I sent as preview photo

@7223 @Flips-148
Scenario: Seeing Preview Photo when the last message is read but I have some unread messages on the same conversation
  Given I am on the "Inbox" screen
  When I have a conversation where my last message is read
  But I have one unread message on it
  Then I should see the first frame of this unread message as preview photo

@7223 @Flips-148
Scenario: Seeing Preview Photo when I have more than one unread message on the conversation
  Given I am on the "Inbox" screen
  When I have more than one unread message on the same conversation
  Then I should see the first frame of the oldest unread message as preview photo

@7223 @Flips-148
Scenario: Seeing Time Stamp when I have just read messages and the last one is not mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message wasn't sent by me
  Then I should see the time sent of the last message of my conversation as time stamp

@7223 @Flips-148
Scenario: Seeing Time Stamp when I have just read messages and the last one is mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message was sent by me
  Then I should see the time sent of the message that I sent as time stamp

@7223 @Flips-148
Scenario: Seeing Time Stamp when the last message is read but I have some unread messages on the same conversation
  Given I am on the "Inbox" screen
  When I have a conversation where my last message is read
  But I have one unread message on it
  Then I should see the time sent of this unread message as time stamp

@7223 @Flips-148
Scenario: Seeing Time Stamp when I have more than one unread message on the conversation
  Given I am on the "Inbox" screen
  When I have more than one unread message on the same conversation
  Then I should see the time sent of the oldest unread message as time stamp

@7223 @ok @Flips-148
Scenario: Reciving a conversation to a person from another country
  Given I am on "Brasil"
  And It's 10am
  When I send a message to "San Francisco"
  Then The time showed on "Inbox" for the recipient screen should be 6am

@7223 @ok @Flips-148
Scenario: Sending a conversation to a person from another country
  Given I am on "Brasil"
  And It's 10am
  When I send a message to "San Francisco"
  Then The time showed on "Inbox" for the sender screen should be 10am

@7223 @Flips-148 @Flips-26
Scenario: Seeing text on the bottom of the conversation when I have just read messages and the last one is not mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message wasn't sent by me
  Then I should see the beggining of the text of the last message of my conversation on the bottom of the conversation

@7223 @Flips-148 @Flips-26
Scenario: Seeing text on the bottom of the conversation when I have just read messages and the last one is mine
  Given I am on the "Inbox" screen
  When I have a conversation with only read messages
  And The last message was sent by me
  Then I should see the beggining of the text of the message that I sent on the bottom of the conversation

@7223 @Flips-148 @Flips-26
Scenario: Seeing text on the bottom of the conversation when the last message is read but I have some unread messages on the same conversation
  Given I am on the "Inbox" screen
  When I have a conversation where my last message is read
  But I have one unread message on it
  Then I should see "Tap to Play" on the bottom of the conversation

@7223 @Flips-148 @Flips-26
Scenario: Seeing text on the bottom of the conversation when I have more than one unread message on the conversation
  Given I am on the "Inbox" screen
  When I have more than one unread message on the same conversation
  Then I should see "Tap to Play" on the bottom of the conversation

@7225 @ok @Flips-148
Scenario: Swiping a conversation
  Given I am on the "Inbox" screen
  When I swipe left a conversation on the list
  Then I should "Delete" icon

@7225 @ok @Flips-148
Scenario: Deleting a conversation
  Given I am seeing "Delete" icon
  When I drop the conversation
  Then the conversation should not be showed on the list
  But my friend's inbox should still show this conversation

@7225 @nok @Flips-148
Scenario: Deleting all my conversations
  Given I am on the "Inbox" screen
  When I delete all my conversations
  Then I shouldn't see my conversations
  And I can't delete FlipBoys conversation

@7225 @Flips-148 @Flips-132 @Flips-8 @review
Scenario: Logout and Login after delete some conversations
  Given I am on the "Inbox" screen
  And I deleted some conversations
  But I have another conversation read, unread and with a lot of messages
  When I logout and login again
  Then The messages that I deleted should keep deleted
  And The messages that I didn't deleted should keep being displayed with the same number of read and unread messages

@7225 @Flips-148
Scenario: Receiving a message from a user that I deleted the old conversation
  Given I am on the "Inbox" screen
  And I deleted a conversation
  When This user that I deleted a message send me another one
  Then I should receive this new message
  But I shouldn't receive the old messages

@7223 @ok @Flips-148 @Flips-23
Scenario: Receiving a message from a flip's user that I did not received yet
  Given I am on the "Inbox" screen
  When I receive a message from a user that exists on my contacts
  But I never received a message from him/her
  Then I should see this conversation on the top of the screen
  And The other conversations should be sorted by time stamp descending order

@7225 @Flips-148
Scenario: Receiving 2 new messages from the same user
  Given I am on the "Inbox" screen
  And I have a message from the user A
  When The user send me a new message from Import screen or New Flip screen
  Then I should see this new message on the same conversation that I already had from user A

@7225 @Flips-148 @Flips-39 @Flips-37
Scenario: Receiving group's message
  Given I am on the "Inbox" screen
  When I have a group message
  Then the behaviour should be the same of the scenarios above

@7225 @Flips-148
Scenario: Checking the behavior of a big conversation
  Given I am on the "Inbox" screen
  And I have a conversation with more than 20 messages
  When I answer or receive messages
  Then The behaviour should be the same as a small conversation

@7223 @Flips-148 @Flips-23
Scenario: Receiving an answer
  Given I am on the "Inbox" screen
  And I sent a message to a person
  When This person answers my message
  Then I should see this conversation on the top of the screen
  And The other conversations should be sorted by time stamp descending order

@7223 @Flips-148 @Flips-23
Scenario: Receiving a message from someone that I don't have on my contacts
  Given I am on the "Inbox" screen
  When I receive a message from someone that is not on my flip's contacts or phone contacts
  Then I should see this conversation on the top of the screen
  And The other conversations should be sorted by time stamp descending order

#When I receive a message fromsomeone that is not on my contacts then I should see them flips name

@7223 @Flips-148 @Flips-134 @Flips-23
Scenario: Receiving a message sent by import screen
  Given I am on the "Inbox" screen
  When I receive a message sent by Import screen
  Then I should see this conversation on the top of the screen
  And The other conversations should be sorted by time stamp descending order

@7223 @Flips-148 @Flips-23
Scenario: Receiving a message sent by new flips screen
  Given I am on the "Inbox" screen
  When I receive a message sent by New Flips screen
  Then I should see this conversation on the top of the screen
  And The other conversations should be sorted by time stamp descending order

@7223 @Flips-148 @Flips-16
Scenario: Sending a message to someone that does not have flip's account and does not have me as a phone contact
  Given I am on the "Inbox" screen
  When I send a message to someone that doesn't have flips
  And This person does not have my number on her phone's contact
  Then He/she should receive an SMS saying:"You've been Flipped by <first name> <last name>!  Download Flips within 30 days to view your message.  appstore.com/flips"

@7223 @Flips-148 @Flips-16
Scenario: Sending a message to someone that does not have flip's account but have me as a phone contact
  Given I am on the "Inbox" screen
  When I sent a message to someone that doesn't have flips
  And This person have my number on her phone's contact
  Then He/she should receive an SMS saying: "You've been Flipped by <first name> <last name>!  Download Flips within 30 days to view your message.  appstore.com/flips"

@7223 @Flips-148
Scenario: Seeing first frame when it is a picture
  Given I am on the "Inbox" screen
  When I receive a messsage with a picture on the first frame
  Then I should see this picture as previews photo

@7223 @Flips-148
Scenario: Seeing first frame when it is a video
  Given I am on the "Inbox" screen
  When I receive a messsage with a video on the first frame
  Then I should see the thumbnail of the first video as previews photo
  But The video shouldn't starts on the Inbox screen

@7223 @Flips-148 @Flips-43 @Flips-20
Scenario: Seeing first frame when it is just an audio
  Given I am on the "Inbox" screen
  When I receive a messsage with an audio on the first frame and with no picture
  Then I should see this a green color as previews photo
  And The audio shouldn't starts on the Inbox screen

@7223 @ok @Flips-148
Scenario: So much conversations on my list
  Given I am on the "Inbox" screen
  And I have a lot of conversations
  When I have no space to so much conversations
  And I scrolling the screen
  Then A scroll bar should be showed

@7223 @ok @Flips-148 @Flips-30
Scenario: Verifying design screen
  Given I am on the "Inbox" screen
  Then The desing screen should be the same on the prototype design
