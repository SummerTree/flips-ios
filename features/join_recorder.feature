Feature: Take a picture on the mug
  As an user
  I want to recorder videos and take pictures
  So, I can send it to my friends


Scenario: Touching Plus button
  Given I am on the "Join_Word_Photo" screen
  When I touch "Plus" button
  Then I should see "Join Recorder" screen
  And The camera should be with front-facing enabled

#Ben, what should happen in this scenario?
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

#Ben, this message will be showed just on MugBoys Chat? Or at first time for any mug?
Scenario: Showing a message when the word I is selected on MugBoys mug
  Given I am on the "Join Recorder" screen
  When The mug selected is MugBoys mug
  And I selected the word I
  Then I should see the message: "You look good today! Let's record a selfie. Tap & Hold to record a video"

Scenario: Showing a message when the word LOVE is selected on MugBoys mug
  Given I am on the "Join Recorder" screen
  When The mug selected is MugBoys mug
  And I selected the word LOVE
  Then I should see the message: "You're doing great! Let's snap a photo this time. Tap to capture a photo"

Scenario: Showing a message when the last word is selected on MugBoys mug
  Given I am on the "Join Recorder" screen
  When The mug selected is MugBoys mug
  And I selected the last word
  Then I should see the message: "Last one! Take the driver seat on this one and be as creative as you want. We'll be here when you get back!"

Scenario: Showing a message when the word I is selected on any mug
  Given I am on the "Join Recorder" screen
  When The mug selected is not MugBoys mug
  And I selected the word I
  Then I should not see the message: "You look good today! Let's record a selfie. Tap & Hold to record a video"

Scenario: Showing a message when the word LOVE is selected on any mug
  Given I am on the "Join Recorder" screen
  When The mug selected is not MugBoys mug
  And I selected the word LOVE
  Then I should not see the message: "You're doing great! Let's snap a photo this time. Tap to capture a photo"

Scenario: Showing a message when the last word is selected on any mug
  Given I am on the "Join Recorder" screen
  When The mug selected is not MugBoys mug
  And I selected the last word
  Then I should not see the message: "Last one! Take the driver seat on this one and be as creative as you want. We'll be here when you get back!"

Scenario: Showing words
  Given I am on the "Join Recorder" screen
  Then I should see all words that I typed on the previous screen

Scenario: Showing joined words
  Given I am on the "Join Recorder" screen
  When I have a joined word
  Then I should see both words in only one group of words

#Ben, is just it? The word have to has some specific characteristic?
Scenario: Spliting words
  Given I am on the "Join Recorder" screen
  When I have only one word
  And I touch it
  Then I should see "Split" option

Scenario: Showing split words
  Given I am seeing "Split" option
  When I touch it
  Then I should see 2 words

#waiting for Ben
Scenario: Seeing icons when I have a video/photo selected
  Given I am on the "Join Recorder" screen
  And I have a video/photo selected
  Then I should see "Flash Camera" icon
  And I should see "Rotate Camera" icon
  And I should see "Microphone" icon

#waiting for Ben
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

#Waiting for Ben
Scenario: Selecting Love word before has a picture to word I
  Given I am on the "Join Recorder" screen
  And I don't have a video or photo selected to word I
  When I touch word "Love"
  And I select a video or photo
  Then ??

Scenario: Don't selecting a word
  Given I am on the "Join Recorder" screen
  When I try don't have any word selected
  Then I should not do it

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

Scenario: Verifying title screen when the mug has only one person
  Given I am on the "Join Recorder" screen
  When I have a mug with only one person
  Then I should see person's name who send me the mug as a title

Scenario: Verifying title screen when the mug has more than one person
  Given I am on the "Join Recorder" screen
  When I have a mug with only more than one person
  Then I should see "Group Chat" as a title

Scenario: Verifying design screen
  Given I am on the "Join Recorder" screen
  Then The desing screen should be the same on the prototype design
