Feature: Recorder a video
  As a user
  I want to recorder a video
  So, I can send it to my friends

Scenario: Touching recorder icon
  Given I am on the "Join Recorder" screen
  And There is a word selected
  When I touch "Recorder" icon
  Then I should see "Recorder" screen

Scenario: Touching Back button
  Given I am on the "Recorder" screen
  When I touch "Back" button
  Then I should see "Join Recorder" screen

#Ben, the Preview button will be always disable on this screen?
Scenario: Preview button
  Given I am on the "Recorder" screen
  Then I should see "Preview" button disable

Scenario: Touching recorder icon
  Given I am on the "Recorder" screen
  When I touch the "Recoder" icon
  Then I should see the "Confirm" screen

Scenario: Touching and holding recorder icon
  Given I am on the "Recorder" screen
  When I touch and hold "Recorder" icon
  Then The recorder should starts
  And I should see a thermometer with the progress
  And After one second I should see the "Confirm" screen

Scenario: Words that already have a mug
  Given I am on the "Recorder" screen
  When The word already has another mug
  Then I should see "..." icon on the top of word

Scenario: Words that don't have a mug
  Given I am on the "Recorder" screen
  When The word doesn't hahave another mug
  Then I shouldn't see "..." icon on the top of word

#Waiting for Ben
Scenario: Selecting Love word before has a picture to word I
  Given I am on the "Recorder" screen
  And I don't have a video or photo selected to word I
  When I touch word "Love"
  And I select a video or photo
  Then ??

Scenario: Don't selecting a word
  Given I am on the "Recorder" screen
  When I try don't have any word selected
  Then I should not do it

Scenario: Verifying title screen when the mug has only one person
  Given I am on the "Recorder" screen
  When I have a mug with only one person
  Then I should see person's name who send me the mug as a title

Scenario: Verifying title screen when the mug has more than one person
  Given I am on the "Recorder" screen
  When I have a mug with only more than one person
  Then I should see "Group Chat" as a title

Scenario: Verifying design screen
  Given I am on the "Recorder" screen
  Then The desing screen should be the same on the prototype design
