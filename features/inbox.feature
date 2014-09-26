Feature: Inbox screen
  As a user
  I want to have a organizated list
  So I can see all of my mugs

Scenario: Access Inbox screen by login screen
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mug@mail.com"
  And I fill "Password" with the value: "Mugchat1"
  And I touch "Done" button
  Then I should see "Inbox" screen

Scenario: Access Inbox screen by New password screen
  Given I am on the "New Password" screen
  When I fill "New Password" whit "MugTest1"
  And I touch "Done" button
  Then I should see "Inbox" screen

Scenario: Access Inbox screen by Register screen
  Given I am on the "Register" screen
  When I fill all fields with valid values
  Then I should see "Inbox" screen

Scenario: Seeing MugBoys mug
  Given It is the first time that I log in on the app
  When I am on the "Inbox" screen
  Then I should see "MugBoys" mug

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
  When I have read and unread messages sent by the same person in the same Mug
  Then I should see just one iten on the list
  And I should see a badge over avatar with the total unread messages

Scenario: Person's photo mug when the message has more than one person and read and unread messages
  Given I am on the "Inbox" screen
  And I have a mug with more than one person
  When I have read and unread messages sent by diferent people in the same Mug
  Then I should see the person's photo from the guy who sent the 1st unread message

Scenario: Total of people when there is more than one person on a mug
  Given I am on the "Inbox" screen
  When I have a mug with more than one person
  Then Bottom of the mug I should see all people's name in the mug

Scenario: Person's photo mug when the message has more than one person and only read messages
  Given I am on the "Inbox" screen
  And I have a mug with more than one person
  When I have only read messages sent by diferent people in the same Mug
  Then I should see the person's photo from the last guy who sent message

Scenario: Person's photo when I have a mug with just one person
  Given I am on the "Inbox" screen
  And I have a mug with just a person
  When I have unread or read messages
  Then I should see person's photo

Scenario: Background's photo mug when the message has more than one person and read and unread messages
  Given I am on the "Inbox" screen
  And I have a mug with more than one person
  When I have read and unread messages sent by diferent people in the same Mug
  Then I should see the first image sent like background

Scenario: Background's photo mug when the message has more than one person and only read messages
  Given I am on the "Inbox" screen
  And I have a mug with more than one person
  When I have only read messages sent by diferent people in the same Mug
  Then I should see the first image sent like background

Scenario: Background's photo when I have a mug with just one person
  Given I am on the "Inbox" screen
  And I have a mug with just a person
  When I have unread or read messages
  Then I should see the first image sent like background

Scenario: Sending a mug to a person from another country
  Given I am on "Brasil"
  And It's 10am
  When I send a mug to "EUA"
  Then The time showed on "Inbox" screen should be 6am

Scenario: Time when I have read and unread messages
  Given I am on the "Inbox" screen
  When I have read and unread messages in the same Mug
  Then I should see the time for the last message send me

Scenario: Time when I have only read messages
  Given I am on the "Inbox" screen
  When I have only read messages in the same Mug
  Then I should see the time for the last message send me

Scenario: Swiping a mug
  Given I am on the "Inbox" screen
  When I swipe left or right a mug on the list
  Then I should "Delete" icon

Scenario: Deleting a mug
  Given I am seeing "Delete" icon
  When I drop the mug
  Then the mug should not be showed on the list
  But my friend's mug should show this mug yet

Scenario: Deleting all my mugs
  Given I am on the "Inbox" screen
  When I delete all my mugs
  Then I shouldn't see my mugs
  And I can't to delete MugBoys mug

Scenario: Receiving a new mug
  Given I am on the "Inbox" screen
  And I have Mugs on my list
  When I receive a new mug
  Then It should be on the top of the list

Scenario: So much mugs on my list
  Given I am on the "Inbox" screen
  And I have a lot of mugs
  When I have no space to so much mugs
  Then A scroll bar should be showed

Scenario: Touching a mug
  Given I am on the "Inbox" screen
  When I touch a mug on the list
  Then I should see "View Mug" screen

Scenario: Touching Construction icon
  Given I am on the "Inbox" screen
  When I touch the "Construction" icon
  Then I should see "Builder" screen

Scenario: Verifying design screen
  Given I am on the "Inbox" screen
  Then The desing screen should be the same on the prototype design
