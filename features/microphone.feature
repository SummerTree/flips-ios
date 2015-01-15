Feature: Microphone recorder
  As a user
  I want to recorder a voice
  So, I can send a Flips to my friends with image and voice

@7453
Scenario: Accessing Microphone screen
  Given I am on the "Compose" screen
  And I'm seeing "Yellow" button
  When I touch "<option>" button
  Then I should see "Microphone" screen
  | option     |
  | Yellow     |
  | Microphone |

@7453
Scenario: Recording voice when the microphone is disable on device
   Given I am on the "Microphone" screen
   And My microphone is disable
   When I touch "Microphone" icon
   Then I should see a friendly message saying that my microphone is disable
   And I shouldn't see the green progress bar

@7453
Scenario: Microphone screen
  Given I am on the "Microphone" screen
  Then I should see "Microphone Recorder" icon
  And I should see "Cancel recorder" icon

@7453
Scenario: It is the first time that I am accessing Microphone screen
  Given I am never access "Microphone" screen in this device
  When I go to "Microphone" screen
  Then I should see a message: ""Flips" Would Like to Access Your Microphone" buttons: "Don't Allow", "Allow"

@7453
Scenario: It is not the first time that I am accessing Microphone screen
  Given I am already access "Microphone" screen in this device
  When I go to "Microphone" screen
  Then I should not see a message: ""Flips" Would Like to Access Your Microphone" buttons: "Don't Allow", "Allow"

@7453
Scenario: Don't allow the microphone
  Given I am on the "Microphone" screen
  And I touch "Microphone Recorder" icon
  When I touch "Don't Allow"
  Then I should see "Compose" screen

@7453
Scenario: Allow the microphone
  Given I am on the "Microphone" screen
  And I touch "Microphone Recorder" icon
  When I touch "OK"
  Then I should keeps seeing "Microphone" screen

@7453
Scenario: Touching X button without record
  Given I am on the "Microphone" screen
  And I didn't record anything
  When I touch "X" button
  Then I should see "Confirm Flips" screen
  And The audio shouldn't be saved

@7453
Scenario: Holding Microphone button more than one second
  Given I am on the "Microphone" screen
  When I hold "Yellow Microphone" button for 4 seconds
  Then An audio should be recorded with 1 second

@7453
Scenario: Tapping Microphone button
  Given I am on the "Microphone" screen
  When I tap "Yellow Microphone" button
  Then A record with 1 second should be recorder
  And I should stay in the "Microphone" screen

@7453
Scenario: Holding Microphone button for one second
  Given I am on the "Microphone" screen
  When I hold "Yellow Microphone" button for 1 second
  Then An audio should be recorded with 1 second

@7453
Scenario: Showing progress bar
  Given I am on the "Microphone" screen
  When I hold "Yellow Microphone" button
  Then I should see a progress bar across the top of the frame

@7453
Scenario: Finishing audio record
  Given I am on the "Microphone" screen
  When I touch "Yellow Microphone" button
  And 1 second is gone
  Then I should see "Confirm Flips" screen
  And The audio should be saved

Scenario: Verifying title screen when the message has only one person
  Given I am on the "Microphone" screen
  When I have a message with only one person
  Then I should see person's name who send me the message as a title

Scenario: Verifying title screen when the message has more than one person
  Given I am on the "Microphone" screen
  When I have a message with more than one person
  Then I should see "Group Chat" as a title

Scenario: Verifying design screen
  Given I am on the "Microphone" screen
  Then The desing screen should be the same on the prototype design
