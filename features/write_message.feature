Feature: Writing a reply or a new mug
  As a user
  I want to write a message to my frinds
  So, They can see my pictures, videos and words


Scenario: Showing user message when the user is replying MugBoys conversation
  Given I am on the "View Mug" screen
  And I am watching MugBoys message
  When I touch "Chat bubble" icon
  Then I should see a purple ballon with the message: Just for fun, lets type I love MugChat

Scenario: Showing user message when the user is replying a mug didn't send by MugChat
  Given I am on the "View Mug" screen
  And I am watching MugBoys mug
  When I touch "Chat bubble" icon
  Then I shouldn't see the purple ballon

@7446
Scenario: Touching Reply button
  Given I am on the "View Mug" screen
  When I touch "Chat bubble" icon
  Then I should see a text field
  And I should see "Next" button disable

@7446
Scenario: Writing a message to reply
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write a character
  Then I should see "Next" button enable

#1 line, after 2 lines, we can scroll message up and down
@7446
Scenario: Writing a message with a lot of characters
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write 100 characters
  And I touch "Next" button
  Then I should see "Compose" screen
  And The first word should be selected

@7446
Scenario: Access Compose screen
  Given I am on the "View Mug" screen
  When I write a reply
  And I touch "Next" button
  Then I should see "Compose" screen
  And The first word should be selected

@7447
Scenario: Showing Join option when there is a space between them
  Given I am on the "View Mug" screen
  And I am writing San Francisco
  When I select these both words
  Then I should see "Join" option

@7447
Scenario: Showing Join option when there is a punctuation between them
  Given I am on the "View Mug" screen
  And I am writing San.Francisco
  When I select these both words
  Then I should see "Join" option

@7447
Scenario: Joining words
  Given I am on the "View Mug" screen
  And I am seeing "Join" option
  When I touch "Join" option
  Then I should see these words in a blue color

@7447
Scenario: join and go to next screen: I should see both words in just one circle
