Feature: Builder screen
  As an user
  I want to register words that I use a lot
  So, I don't need to take a picture or video every time

Scenario: Access Builder screen for the first time
  Given I am on the "Onboarding" screen
  When I touch "Builder" icon
  Then I should see a screen with a message: Hi <user>, this is your word builder. It's a quick & esasy tool to define & add words to use for future messages. We have suggested words to get you started, but feel free to add as many words as you like.
  And I should see: "ok, sweet!" button

Scenario: Touching ok, sweet button
  Given I am seeing the first time user's message
  When I touch "ok, sweet!" button
  Then I should see the "Builder" screen  

Scenario: Access Builder screen for the second time
  Given I am on the "Onboarding" screen
  When I touch "Builder" icon
  Then I should see "Builder" screen

Scenario: Touching Back button
  Given I am on the "Builder" screen
  When I touch "Back" button
  Then I should see "Onboading" screen

Scenario: Add a new word
  Given I am on the "Builder" screen
  When I touch "Plus" icon
  And I type a word that doesn't exists on the list
  And I touch "Done" button
  Then I should see "Builder" screen
  And I should see the word created

Scenario: Seeing the new word on the list
  Given I am on the "Builder" screen
  And I include a new word
  When I touch "Plus" icon
  Then The word should be include on the top of the list

Scenario: Seeing words come from the server
  Given I am on the "Builder" screen
  When I touch "Plus" icon
  Then I should see the server words

Scenario: Seeing words that I sent to my friends
  Given I am on the "Builder" screen
  When I touch "Plus" icon
  Then I should see the words that I sent to my friends

Scenario: Searching a word
  Given I am on the "Builder" screen
  When I touch "Plus" icon
  And I type a word that already exists on the list
  Then I should see just this word on the list

Scenario: Searching for 2 or 3 charactes
  Given I am on the "Builder" screen
  When I touch "Plus" icon
  And I type 2 or 3 characters that more than one word has this string
  Then I should see only these words on the list

Scenario: Taking a picture to the new word
  Given I am on the "Builder" screen
  When I take a picture
  Then The first word in the list is bound to the picture taken

Scenario: Verifying title screen
  Given I am on the "Builder" screen
  Then I should see "Builder" as a title

Scenario: Verifying design screen
  Given I am on the "Builder" screen
  Then The desing screen should be the same on the prototype design
