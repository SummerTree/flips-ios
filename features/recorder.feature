Scenario: Touching recorder icon
  Given I am on the "Join Recorder" screen
  And There is a word selected
  When I touch "Recorder" icon
  Then I should see "Recorder" screen

Scenario: Touching Back button
  Given I am on the "Recorder" screen
  When I touch "Back" button
  Then I should see "Join Recorder" screen

#Aguardar resposta do Ben
Scenario: Preview button
  Given I am on the "Recorder" screen
  Then I should see "Preview" button disable

Scenario: Touching recorder icon
  Given I am on the "Recorder" screen
  When I touch the "Recoder" icon
  Then I should see the "Confirm" screen
  And I should see the pictures taken

Scenario: Touching and holding recorder icon
  Given I am on the "Recorder" screen
  When I touch and hold "Recorder" icon
  Then After one second I should see the "Confirm" screen
  And I should see the video recorded

Scenario: Words that already have a mug
  Given I am on the "Recorder" screen
  When The word already has another mug
  Then I should see "..." icon on the top of word

Scenario: Words that don't have a mug
  Given I am on the "Recorder" screen
  When The word doesn't hahave another mug
  Then I shouldn't see "..." icon on the top of word

#Aguardar a resposta do Ben
Scenario: Selecting Love picture before I picture
  Given I am on the "Recorder" screen
  And I don't have a video or photo selected to word I
  When I touch word "Love"
  And I select a video or photo
  Then ??

Scenario: Don't selecting a word
  Given I am on the "Recorder" screen
  When I try don't have any word selected
  Then I should not can

#Aguardar a resposta do Ben
Scenario: Seeing Albums icon when I don't have albums and pictures on my device
  Given I am on the "Recorder" screen
  When I don't have Albums and pictures on my devide
  Then ???

Scenario: Selecting a picture on my album
  Given I am on the "Recorder" screen
  And I go to "Select Picture" screen
  When I touch a picture
  Then I should see "Join Recorder" screen
  And I should see the imagem touched

Scenario: Touching Back button select albuns screen
  Given I am on the "Recorder" screen
  And I go to "Select Picture" screen
  When I touch "Back" button
  Then I should see "Join Recorder" screen
