Feature: Builder screen
  As an user
  I want to register words that I use a lot
  //This should be "I want to quickly record words into my personal dictionary"
  So, I don't need to take a picture or video every time
  //"So that they will be available to me the next time I type a message"

Scenario: Access Builder screen for the first time
  Given I am on the "Onboarding" screen  //This should occur upon the user's first time arriving at the Builder screen.  It doensn't have to be during Onboarding... the user could wait 3 weeks before tapping the "Builder" button from the Inbox screen, and they should still see the explainer message.
  When I touch "Builder" icon
  Then I should see a screen with a message: Hi <user>, this is your word builder. It's a quick & esasy tool to define & add words to use for future messages. We have suggested words to get you started, but feel free to add as many words as you like.
  And I should see: "ok, sweet!" button

Scenario: Touching ok, sweet button
  Given I am seeing the first time user's message
  When I touch "ok, sweet!" button
  Then I should see the "Builder" screen
  And I should see any words sent by the server listed in the queue, ready to be recorded

Scenario: Access Builder screen for the second time
  Given I am on the "Onboarding" screen  //This should be from the "Inbox" screen
  When I touch "Builder" icon
  Then I should see "Builder" screen

Scenario: Touching Back button
  Given I am on the "Builder" screen
  When I touch "Back" button
  Then I should see "Onboading" screen  //"Inbox" screen, not Onboarding
  
Scenario: Open Builder Word Queue List
  Given that I am on the "Builder" screen
  When I touch "Plus" icon
  Then I should see the "Builder Word Queue List" screen

Scenario: Add a new word or phrase to the queue
  Given I am on the "Builder Word Queue List" screen
  And I type a word or phrase
  And I touch "Next" on the keyboard
  Then I should see the previous words in the list are moved down
  And the new word or phrase added to the top of the list
  
Scenario: Newly added word appears in recording queue
  Given that I am on the "Builder Word Queue List" screen
  And I have added a new word or phrase to the list
  When I touch "Done"
  Then I should see the "Builder" screen with the new word at the front of the queue

Scenario: Recording a new video for a word in the queue
  Given that I am on the "Builder" screen
  And there is a word centered above the record button
  When I tap and hold the camera shutter button
  And I record a video
  Then I should see the outline around the word bubble fill green
  And the recorded word should move to the left
  And the next word should move to the left to become centered above the shutter button, ready to record

Scenario: Taking a new photo for a word in the queue
  Given I am on the "Builder" screen
  And there is a word centered above the record button
  When I tap and release the shutter button
  And I take a photo
  Then I should see the camera button replaced by a microphone button
  
Scenario: Selecting an existing photo from my camera roll for a word in the queue
  Given I am on the "Builder" screen
  And there is a word centered above the record button
  When I touch the thumbnail icon
  And I see the "Camera Roll" screen
  And I select a photo
  And I see the "Builder" screen again
  Then I should see the camera button replaced by a microphone button
  
Scenario: Adding a audio recording to the photo
  Given that I am on the "Builder" screen
  And I have taken or selected a photo for a word
  And the microphone button is shown
  When I tap and hold on the microphone button
  And I record audio
  Then I should see the outline around the word bubble fill green
  And the recorded word should move to the left
  And the next word should move to the left to become centered above the shutter button, ready to record

Scenario: Verifying title screen
  Given I am on the "Builder" screen
  Then I should see "Builder" as a title

Scenario: Verifying design screen
  Given I am on the "Builder" screen
  Then The desing screen should be the same on the prototype design
