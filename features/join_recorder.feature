Feature:
  As an user
  I want
  So, I can


Scenario: Touching Plus button
  Given I am on the "Join_Word_Photo" screen
  When I touch "Plus" button
  Then I should see "Join Recorder" screen

#Ver com Ben
Scenario: Touching Preview button without video/photo
  Given I am on the "Join Recorder" screen
  When I don't have a video or photo
  And I touch "Preview" button
  Then ???

Scenario: Touching Preview button when there is a video/photo
  Given I am on the "Join Recorder" screen
  When I have a video or photo
  And I touch "Preview" button
  Then I should see "Preview" screen

Scenario: Touching Back button
  Given I am on the "Join Recorder" screen
  When I touch "Back" button
  Then I should see "View Mug" screen

Scenario: Words that already have a mug
  Given I am on the "Join Recorder" screen
  When The word already has another mug
  Then I should see "..." icon on the top of word

Scenario: Words that don't have a mug
  Given I am on the "Join Recorder" screen
  When The word doesn't hahave another mug
  Then I shouldn't see "..." icon on the top of word

#Aguardar a resposta do Ben
Scenario: Seeing icons when I have a video/photo selected
  Given I am on the "Join Recorder" screen
  And I have a video/photo selected
  Then I should see "Flash Camera" icon
  And I should see "Rotate Camera" icon
  And I should see "Microphone" icon

#Aguardar a resposta do Ben
Scenario: Seeing icons when I don't have a video/photo selected
  Given I am on the "Join Recorder" screen
  And I don't have a video/photo selected
  Then I shouldn't  see "Flash Camera" icon
  And I shouldn't see "Rotate Camera" icon
  And I shouldn't see "Microphone" icon

Scenario: Touch flash button when the camera is in front
  Given I am on the "Join Recorder" screen
  When I touch "Flash" button
  Then the button should be disable

Scenario: Disable flash button
  Given I am on the "Join Recorder" screen
  And the camera is rotate back
  And the flash is on
  When I touch "Flash" button
  Then the flash should be off

Scenario: Enable flash button
  Given I am on the "Join Recorder" screen
  And the camera is rotate back
  And the flash is off
  When I touch "Flash" button
  Then the flash should be on

Scenario: Rotate back camera
 Given I am on the "Join Recorder" screen
 And the camera is in front of device
 When I touch "Camera" button
 Then the camera should rotate to back

Scenario: Rotate in front camera
 Given I am on the "Join Recorder" screen
 And the camera is in back of device
 When I touch "Camera" button
 Then the camera should rotate to in front

Scenario: Touching Microphone icon
  Given I am on the "Join Recorder" screen
  When I touch "Microphone" icon
  Then ???

#Aguardar a resposta do Ben
Scenario: Selecting Love picture before I picture
  Given I am on the "Join Recorder" screen
  And I don't have a video or photo selected to word I
  When I touch word "Love"
  And I select a video or photo
  Then ??

Scenario: Don't selecting a word
  Given I am on the "Join Recorder" screen
  When I try don't have any word selected
  Then I should not can

Scenario: Touching recorder icon
  Given I am on the "Join Recorder" screen
  And There is a word selected
  When I touch "Recorder" icon
  Then I should see "Recorder" screen

Scenario: re-recorder a video/photo
  Given I am on the "Join Recorder" screen
  And I already have a photo/video selected
  When I recorder another photo/video
  Then I should see this new photo/video

#Aguardar a resposta do Ben
Scenario: Seeing Albums icon when I don't have albums and pictures on my device
  Given I am on the "Join Recorder" screen
  When I don't have Albums and pictures on my devide
  Then ???

Scenario: Selecting a picture on my album
  Given I am on the "Select Picture" screen
  When I touch a picture
  Then I should see "Join Recorder" screen
  And I should see the imagem touched

Scenario: Touching Back button select albuns screen
  Given I am on the "Select Albums" screen
  When I touch "Back" button
  Then I should see "Join Recorder" screen
