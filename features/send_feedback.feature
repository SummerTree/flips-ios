Feature: Send FeedBack screen
  As a user
  I want to send suggestions to mugchat time
  So I can access Send Feedback on settings

Scenario: Access Send FeedBack screen
  Given I am on the "Settings" scren
  When I touch "Send FeedBack" option
  Then I should see "Send FeedBack" screen

Scenario: Showing Send feedback screen
  Given I am on the "Settings" scren
  When I touch "Send FeedBack" option
  Then I should see the MugBoys Welcome message
  But The video shouldn't starts
  And I should see all words of the mug

Scenario: Writing a message
  Given I am on the "Send FeedBack" screen
  When I touch "Talk" icon
  Then I should see a text field
  And I should see "Next" button disable

Scenario: Next button enable
  Given I am on the "Send FeedBack" screen
  When I write a message
  Then I should see "Next" button enable

Scenario: Touching Next button
  Given I am on the "Send FeedBack" screen
  And There is a message typed
  When I touch "Next" button
  Then I should see "Join_Word_Photo" screen

#Ben, is there a maximum of words/charactes that I can type?
Scenario: Writing a lot of words on text field
  Given I am on the "Send FeedBack" screen
  And I am seeing the Text field
  When I write more than XX characters
  And I touch "Next" button
  Then I should ????

Scenario: Verifying title screen
  Given I am on the "Send FeedBack" screen
  Then I should see "MugBoys" as a title

Scenario: Verifying design screen
  Given I am on the "Send FeedBack" screen
  Then The desing screen should be the same on the prototype design
