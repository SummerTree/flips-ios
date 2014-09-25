Feature: Take Picture
  As a user
  I want to choose which photo my frieds will see on my profile
  So I can pick up a photo

Scenario: Touching Photo icon
  Given I am on the "Register" screen
  And All fields are filled
  When I touch "Image" icon
  Then I should see "Take Picture" screen

Scenario: Accessing Take Picture screen by User Information
  Given I am on the "User Information" screen
  When I touch "Image" icon
  Then I should see "Take Picture" screen

Scenario: Touching Back button
  Given I am on the "Take Picture" screen
  When I touch "Back" button
  Then I should see "Register" screen

Scenario: Seeing the image camera
  Given I am on the "Take Picture" screen
  Then The image camera should be showed with a circle

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

Scenario: Verifying title screen
  Given I am on the "Take Picture" screen
  Then I should see "Take Picture" as a title

Scenario: Verifying design screen
  Given I am on the "Take Picture" screen
  Then The desing screen should be the same on the prototype design
