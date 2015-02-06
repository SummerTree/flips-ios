Feature: Accepting Test to Send audio between 2 devices
  As a user
  I want to do some tests on send pictures feature to make sure that these features are Ok
  So, I know that it is ready

Scenario: Answer Bruno's message flips with audio
  Given I am "View Flip" screen
  And I am seeing a text field to reply Bruno's message
  When I type a message: Hi Bruno!!!
  And I touch "Next" button
  Then I should see "Compose" screen

Scenario: Recorder an audio to word Hi
  Given I am on the "Compose" screen
  And The word "Hi" is selected
  When I take a picture
  And I hold "Microphone" button
  Then I should see "Confirm" screen
  And I should see the picture taken
  And I should listen the audio recorded

Scenario: Stopping audio on Confirm screen
  Given I am on the "Confirm" screen
  And I'm listening an audio
  When I touch the image
  Then The audio should stop

Scenario: Taking only a picture to word Bruno
  Given I am on the "Confirm" screen
  And I confirm the picture and audio from word Hi
  And I go to "Compose" screen with word Bruno selected
  When I touch "Yellow" button
  And I touch "Cancel Mic" button
  Then I should see "Confirm" screen again
  And I shouldn't listen the audio

Scenario: Touching Microphone icon under the rotate button
  Given I am on the "Confirm" screen
  And I confirm the picture from word Bruno
  And I go to "Compose" screen with word "!!!" selected
  When I touch "Microphone" icon from camera area (under the rotate button)
  Then I should see "Microphone" and "Cancel Mic"  button

Scenario: Recording only audio to word !!!
  Given I am on the "Compose" screen
  And The word "!!!" is selected
  And I am seeing "Microphone" and "Cancel Mic" button
  And I hold "Microphone" button
  Then I should see "Confirm" screen
  And I shouldn't see the picture taken
  And I should listen the audio recorded

Scenario: Touching Preview
  Given I am on the "Compose" screen
  And I recorded audio to words "Hi" and "!!!"
  And I recorded picture to words "Hi" and "Bruno"
  When I touch "Preview" button
  Then I should see "Preview" button
  And I should see word "Hi" with picture and audio
  And I should see word "Bruno" with picture
  And I should see word "!!!" with a green background and audio

Scenario: Sending a answer with audio
  Given I am on the "Preview" screen
  When I touch "Send" button
  Then I should "Inbox" screen
  And I should see this message on the inbox screen
  And The message should appear on the inbox screen from Caio's user

Scenario: Receiving a Flip message with audio
  Given I am logged with Caio's account: bruno@gmail.com, password: Password1
  When I am on the "Inbox" screen
  Then I should see the first image from the message sent

Scenario: Seeing audio messages
  Given I am on Inbox screen
  And I am logged with Bruno's account
  When I type the message sent from Caio's user
  Then I should see word "Hi" with image and audio
  And I should see word "Bruno" with image and audio
  And I should see word "!!!" with image and audio
