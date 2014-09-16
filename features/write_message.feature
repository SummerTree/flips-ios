Feature: Writing a reply or a new mug
  As a user
  I want to write a message to my frinds
  So, They can see my pictures, videos and words

#Ben, the purple ballon will be showed on MugBoys mug or only the first time in anyone mug?
Scenario: Showing user message when the user is replying MugBoys mug
  Given I am on the "View Mug" screen
  And I am watching MugBoys mug
  When I touch "Reply" icon
  Then I should see a purple ballon with the message: Just for fun, lets type I love MugChat

#Ben, the purple ballon will be showed on MugBoys mug or only the first time in anyone mug?
Scenario: Showing user message when the user is replying a mug didn't send by MugChat
  Given I am on the "View Mug" screen
  And I am watching MugBoys mug
  When I touch "Reply" icon
  Then I shouldn't see the purple ballon

Scenario: Showing Join option
  Given I am on the "View Mug" screen
  And I am writing San Francisco
  When I select these both words
  Then I should see "Join" option

Scenario: Joining words
  Given I am on the "View Mug" screen
  And I am seeing "Join" option
  When I touch "Join" option
  Then I should see only one word
  
