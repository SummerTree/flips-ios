Feature: Accepting Test to Send videos between 2 devices
  As a user
  I want to do some tests on send videos feature to make sure that these features are Ok
  So, I know that it is ready

Scenario: Answer Caio's message flips with video
  Given I am "View Flip" screen
  And I am seeing a text field to reply Caio's message
  When I type a message: Let's go now?
  And I touch "Next" button
  Then I should see "Compose" screen
  And I should see word "Let's" selected

Scenario: Recording a video to word Let's
  Given I am on the "Compose" screen
  And Word "Let's" is selected
  When I hold yellow button
  Then I should see "Confirm" screen
  And I should see the video recorded with image and sound

Scenario: Confirming a video
  Given I am on the "Confirm" screen
  And the video is playing
  When I touch "√" button
  Then I should see "Compose" screen
  And I should see word "go" selected

Scenario: Taking a picture to word go
  Given I am on the "Compose" screen
  And Word "go" is selected
  When I touch "Yellow" button
  Then I should see "Confirm" screen
  And I should see the picture taken

Scenario: Recorder an audio to word now
  Given I am on the "Confirm" screen
  And I confirm the picture
  And I go to "Compose" screen
  And Word "Now" is selected
  When I recorder an audio to this word
  Then I should see "Confirm" screen
  And I should see the audio recorded

Scenario: Touching Preview button
  Given I am on the "Confirm" screen
  And I confirm the audio
  And I go to "Compose" screen
  And Word "?" is selected
  When I touch "Preview" button
  Then I should see "Preview" screen
  And I should see the video to word: "Let's"
  And I should see the picture to word: "go"
  And I should see nothing to word: "?"

Scenario: Sending message
  Given I am on the "Preview" screen
  When I touch "Send" button
  Then I should see "Inbox" screen
  And The message should be sent to Caio's account

Scenario: Receiving a video message
  Given I am logged in with Caio's account
  And I am on the "Inbox" screen
  And I am seeing the message sent on this scenarios
  When I touch this message
  Then I should see all words with their respective images, audio and videos
