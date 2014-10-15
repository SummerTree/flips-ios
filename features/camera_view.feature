Feature: Camera View screen
  As a user
  I want to choose which photo my frieds will see on my profile
  So I can pick up a photo

@7174
Scenario: Accessing Camera View screen by Avatar icon
  Given I am on the "Register" screen
  And All fields are filled
  When I touch "Avatar" icon
  Then I should see "Camera View" screen

@7174
Scenario: Accessing Camera View screen by User Information
  Given I am on the "User Information" screen
  When I touch "Avatar" icon
  Then I should see "Camera View" screen

@7174
Scenario: Touching Back button
  Given I am on the "<screen>"
  And I go to "Camera View" screen
  When I touch "Back" button
  Then I should see "<screen>" screen
  | screen           |
  | Register         |
  | User Information |

@7174
Scenario: Seeing the image camera
  Given I am on the "Camera View" screen
  Then I should see the front-facing camera
  And I should see a dark opaque circular mask arround the border

@7174 @7617 @7455
Scenario: Rotate from front-facing to back camera
 Given I am on the "<screen>" screen
 And the camera is in front-facing
 When I touch "Rotate Camera" button
 Then I should see an animation
 And After that I should see back camera
 And I should see "Flash" button enable and with tha last option selected
 | screen      |
 | Camera View |
 | Compose     |

@7174 @7455
Scenario: Turn Flash on
  Given I am on the "<screen>" screen
  And The camera is on back
  And the flash is off
  When I touch "Flash" button
  Then The flash should be on
  | screen      |
  | Camera View |
  | Compose     |

@7174 @7455
Scenario: Turn auto flash on
  Given I am on the "<screen>" screen
  And The camera is on back
  And the flash is on
  When I touch "Flash" button
  Then The flash should be auto
  | screen      |
  | Camera View |
  | Compose     |

@7174 @7455
Scenario: Turn Flash off
  Given I am on the "<screen>" screen
  And the camera is rotate back
  And the flash is on
  When I touch "Flash" button
  Then the flash should be off
  | screen      |
  | Camera View |
  | Compose     |

@7174 @7455
Scenario: Rotate from back camera to front-facing
  Given I am on the "<screen>" screen
  And the camera is rotate back
  When I touch "Rotate Camera" button
  Then I should see front-facing camera
  And I should see "Flash" button disable
  | screen      |
  | Camera View |
  | Compose     |

@7174
Scenario: Verifying title screen
  Given I am on the "Camera View" screen
  Then I should see "Take Picture" as a title

@7174
Scenario: Verifying design screen
  Given I am on the "Camera View" screen
  Then The desing screen should be the same on the prototype design
