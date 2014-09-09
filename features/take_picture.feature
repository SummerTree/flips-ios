Feature: Take Picture
  As an user
  I want to choose which photo my frieds will see on my profile
  So I can pick up a photo

Scenario: Touching Photo icon
  Given I am on the "Register" screen
  And All fields are filled
  When I touch "Image" icon
  Then I should see "Take Picture" screen

Scenario: Touching Photo icon when the fields are not filled
  Given I am on the "Register" screen
  And All fields are filled
  When I touch "Image" icon
  Then Nothing should happend

Scenario: Touching Back button
  Given I am on the "Take Picture" screen
  When I touch "Back" button
  Then I should see "Register" screen

Scenario: Changing the taked photo
  Given I am on the "Register" screen
  And There is a photo already selected
  When I touch the picture
  Then Nothing should happend

Scenario: Touch flash button when the camera is in front
  Given I am on the "Take Picture" screen
  When I touch "Flash" button
  Then the button should be disable

Scenario: Disable flash button
  Given I am on the "Take Picture" screen
  And the camera is rotate back
  And the flash is on
  When I touch "Flash" button
  Then the flash should be off

Scenario: Enable flash button
  Given I am on the "Take Picture" screen
  And the camera is rotate back
  And the flash is off
  When I touch "Flash" button
  Then the flash should be on

Scenario: Rotate back camera
 Given I am on the "Take Picture" screen
 And the camera is in front of device
 When I touch "Camera" button
 Then the camera should rotate to back

Scenario: Rotate in front camera
 Given I am on the "Take Picture" screen
 And the camera is in back of device
 When I touch "Camera" button
 Then the camera should rotate to in front
