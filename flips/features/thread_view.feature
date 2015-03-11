Feature: View Flips screen
  As a user
  I want to see all my received flips
  So, I can read my received flips

@Flips-220
Scenario: Accessing Thread View screen
  Given I am on the "Inbox" screen
  When I touch a conversation on the list
  Then I should see "Thread View" screen

@Flips-220
Scenario: Seeing Thread View screen when I have more than 1 unread message
  Given I am on the "Inbox" screen
  And I have a conversation with 3 or more messages
  And The first message is read
  And There are at least two unread messages
  When I touch this conversation
  Then I should see the oldest unread flips at the top of the screen

@Flips-220
Scenario: Auto play when I open an unread message
  Given I am on the "Inbox" screen
  And I have a conversation with an unread message
  When I touch this conversation
  Then The flips message should starts to play automatically

@Flips-220
Scenario: Seeing words beneath of the video when the message is not read
  Given I am on the "Thread View" screen
  When I am seeing a conversation with an unread message
  Then I shouldn't see words beneath of the video

@Flips-220
Scenario: Starting a message and checking the text beneath of the video
  Given I am on the "Thread View" screen
  When I start an unread message
  Then I shouldn't see words beneath of the video

@Flips-220
Scenario: Pausing a message and checking the text beneath of the video
  Given I am on the "Thread View" screen
  And I am watching an unread message
  When I pause the message
  Then I shouldn't see words beneath of the video

@Flips-220
Scenario: Finishing the message and checking the text beneath of the video
  Given I am watching an unread message
  When The video finishes
  Then I should see all words on the video beneath of the video

@Flips-220
Scenario: Seeing Thread View screen when I have only read messages and the last one was not send by me
  Given I am on the "Inbox" screen
  When I touch a conversation with only read messages
  And the last message was not send by me
  Then I should see the newest message
  And I should see beneath the video the text sent to me on the message

@Flips-220
Scenario: Seeing Thread View screen when I have only read messages and the last one was sent by me
  Given I am on the "Inbox" screen
  When I touch a conversation with only read messages
  And the last message was sent by me
  Then I should see my message
  And I should see beneath the video the text sent to me on the message

@Flips-220
Scenario: Checking if the message is opening correctly
  Given I am on the "Inbox" screen
  When I touch a conversation with more than one message
  Then I shouldn't see the messages scrolling when I open "Thread View" screen

@Flips-220
Scenario: Auto-Play when I am scrolling the list
  Given I am on the "Thread View" screen
  And I am seeing a conversation with more than one message
  When I scroll the list
  And I am seeing a message all square of the message
  Then The message should start automatically

@Flips-220
Scenario: Scrolling a conversation when the video is playing
  Given I am on the "Thread View" screen
  And I am seeing a conversation with more than one message
  When A message is playing
  And I scroll the list
  Then The video should stop automatically as soon as I can't see all square of the message

@Flips-220
Scenario: Pausing a video
  Given I am on the "Thread View" screen
  And I am watching a message
  When I touch the message
  Then The message should pause

@Flips-220
Scenario: Un-Pause a video flips
  Given I am on the "Thread View" screen
  And I am seeing a paused message
  When I touch the message
  Then The message should start where it left off

@Flips-220
Scenario: Seeing screen's title when I have a group conversation
  Given I am on the "Thread View" screen
  When The conversation has more than one person
  Then I should see "<all person's first name>" as the title of the screen

@Flips-220
Scenario: Seeing screen's title when I have a group conversation and I do not have more space to show the names
  Given I am on the "Thread View" screen
  When The conversation has more than one person
  And There is no space on the screen to see all person's name
  Then I should see "<person's first name>" as the title of the screen
  And At the end of the title I should see "..."

@Flips-220
Scenario: Seeing screen's title when I have a conversation with just one person and this person has a flips account
  Given I am on the "Thread View" screen
  When The conversation has just one person
  Then I should see "<flips name>" as the title of the screen

@Flips-220
Scenario: Seeing screen's title when I have a conversation with just one person and this person does not have a flips account
  Given I am on the "Thread View" screen
  When The conversation has just one person
  Then I should see "<contact's name>" as the title of the screen

@Flips-220
Scenario: Seeing screen's title when I sent a message to a contact that was not on Flips but now he is
  Given I am on the "Thread View" screen
  When I am seeing a conversation that the contact wasn't on flips
  But Now he it
  Then I should see "<flips name>" as the title of the screen

@Flips-220
Scenario: Time for each word with video
  Given I am on the "Thread View" screen
  When I am watching a message with <midia>
  Then I should see this word and midia for 1 second
  | midia   |
  | picture |
  | audio   |
  | video   |

@Flips-220
Scenario: Watching a message with more than one word
  Given I am on the "Thread View" screen
  When I am seeing a message with more than 1 word
  Then I should see each word and midia for 1 second

@Flips-220
Scenario: Checking avatar on messages that I received
  Given I am on the "Thread View" screen
  When I am seeing a message sent to me
  Then I should see flips user's avatar from who sent me the message
  And I should see it on the left side and bottom of the message

@Flips-220
Scenario: Checking avatar on messages that I sent
  Given I am on the "Thread View" screen
  When I am seeing a message that I sent to someone
  Then I should see my flips user's avatar
  And I should see it on the right side and bottom of the message

@Flips-220
Scenario: Checking avatar when I receive messages in a group conversation
  Given I am on the "Thread View" screen
  When I am seeing a conversation with a lot of message that I received from different people
  Then I should see each message with the avatar from who sent me it

@Flips-220
Scenario: Showing the time when the message was send from another country
  Given My friend sent me a message from Brasil
  And In Brasil it's 10am
  And I am in San Francisco
  When I go to "Thread View"
  And I watch the flips
  Then The time showed should be 6am

@Flips-220
Scenario: Checking the date/time when I receive or send message today
  Given I am on the "Thread View" screen
  When I am seeing a message that I <action> <time>
  Then I should see on the time stamp the date and time that I <action> the message on this format: <format>
  | action  | time           | format                                   |
  | receive | today          | hh:mm AM/PM                              |
  | send    | today          | hh:mm AM/PM                              |
  | receive | yesterday      | Yesterday, hh:mm AM/PM                   |
  | send    | yesterday      | Yesterday, hh:mm AM/PM                   |
  | receive | last monday    | Monday, hh:mm AM/PM                      |
  | send    | last monday    | Monday, hh:mm AM/PM                      |
  | receive | last tuesday   | Tuesday, hh:mm AM/PM                     |
  | send    | last tuesday   | Tuesday, hh:mm AM/PM                     |
  | receive | last wednesday | Wednesday, hh:mm AM/PM                   |
  | send    | last wednesday | Wednesday, hh:mm AM/PM                   |
  | receive | last thursday  | Thursday, hh:mm AM/PM                    |
  | send    | last thursday  | Thursday, hh:mm AM/PM                    |
  | receive | last friday    | Friday, hh:mm AM/PM                      |
  | send    | last friday    | Friday, hh:mm AM/PM                      |
  | receive | last saturday  | Saturday, hh:mm AM/PM                    |
  | send    | last saturday  | Saturday, hh:mm AM/PM                    |
  | receive | last sunday    | Sunday, hh:mm AM/PM                      |
  | send    | last sunday    | Sunday, hh:mm AM/PM                      |
  | receive | today - 8 days | <Mon - Sun>, <Jan-Dec> <dd>, hh:mm AM/PM |
  | send    | today - 8 days | <Mon - Sun>, <Jan-Dec> <dd>, hh:mm AM/PM |
  | receive | previous year  | <Jan - Dec> <dd> <YYYY>, hh:mm AM/PM     |

@Flips-220
Scenario: Checking the time when I sent a message
  Given I am on the "Thread View" screen
  When I answer a message
  And I go to "Preview" screen
  When I touch "Send" button
  Then I should see "Thread View" screen
  And I should see my message at the end of the thread

@Flips-220
Scenario: Seeing Thread View screen when I have more than 15 messages
  Given I am on the "Thread View" screen
  When I am seeing a thread with more than 15 messages
  Then I should see the first frame of all messages
  And This thread should work fine without crashes

@Flips-220
Scenario: Checking first frame
  Given I am on the "Inbox" screen
  And I have a message that the first word is <midia>
  When I touch this message
  Then I should see the <thumbnail> as thumbnail
  | midia     | thumbnail                |
  | a picture | image                    |
  | nothing   | green image              |
  | video     | first frame of the video |

@Flips-220
Scenario: Touching Back button
  Given I am on the "Thread View" screen
  When I touch "Back" button
  Then I should see "Inbox" screen

@Flips-220
Scenario: Verifying design screen
  Given I am on the "Thread View" screen
  Then The desing screen should be the same on the prototype design
