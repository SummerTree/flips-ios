Feature: Microphone recorder
  As an user
  I want to recorder a voice
  So, I can send a MugChat to my friends with image and voice

Scenario: Acception a take picture by Recorder screen
  Given I am on the "Recorder" screen
  When I take a picture
  And I confirm it
  Then I should see "Microphone" screen

Scenario: Micriphone screen
  Given I am on the "Microphone" screen
  Then I should see "Microphone Recorder" icon
  And I should see "Cancel recorder" icon

#Aguardar resposta do Ben
Scenario: Preview button
  Given I am on the "Microphone" screen
  Then I should see "Preview" button disable

Scenario: Touching microphone recorder icon for the first time
  Given I am on the "Microphone" screen
  And It is the first time that I'll recorder a voice
  When I touch the "Microphone Recorder" icon
  Then I should see the a message: ""MugChat" Woud Like to Access your Microphone"
  And I should see buttons:"Don't Allow" and "OK"

#Ben, what should happen in this scenario?
Scenario: Don't allow the microphone
  Given I am on the "Microphone" screen
  And I touch "Microphone Recorder" icon
  When I touch "Don't Allow"
  Then I should see "Recorder" screen

Scenario: Allow the microphone
  Given I am on the "Microphone" screen
  And I touch "Microphone Recorder" icon
  When I touch "OK"
  Then I should keeps seing "Microphone" screen

Scenario: Recording a voice
  Given I am on the "Microphone" screen
  And I tap and holp "Microphone Recorder" icon
  Then The recorder voice should starts

Scenario: Touching microphone recorder icon for the second time when it was allowed on the first time
  Given I am on the "Microphone" screen
  And It is the second time that I'll recorder a vonce
  And I allowed it on my first time
  When I touch the "Microphone Recorder" icon
  Then The recorder voice should starts

Scenario: Touching microphone recorder icon for the second time when it doesn't allowed on the first time
  Given I am on the "Microphone" screen
  And It is the second time that I'll recorder a vonce
  And I don't allowed it on my first time
  When I touch the "Microphone Recorder" icon
  Then I should see the a message: ""MugChat" Woud Like to Access your Microphone"
  And I should see buttons:"Don't Allow" and "OK"

Scenario: Recording a voice
  Given I am on "Microphone" screen
  And I touch the "Microphone Recorder" icon
  When 1 second is gone
  Then I should see "Confirm" screen

Scenario: Canceling the voice recorder
  Given I am on the "Microphone" screen
  When I touch the "Cancel Microphone Recoder" icon
  Then I should see "Confirm" screen

Scenario: Verifying title screen when the mug has only one person
  Given I am on the "Microphone" screen
  When I have a mug with only one person
  Then I should see person's name who send me the mug as a title

Scenario: Verifying title screen when the mug has more than one person
  Given I am on the "Microphone" screen
  When I have a mug with only more than one person
  Then I should see "Group Chat" as a title

Scenario: Verifying design screen
  Given I am on the "Microphone" screen
  Then The desing screen should be the same on the prototype design
