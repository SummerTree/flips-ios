Feature: Camera View screen
  As a user
  I want to choose which photo my frieds will see on my profile
  So I can pick up a photo

@7174 @Flips-5
Scenario: Accessing Camera View screen by Avatar icon
  Given I am on the "<screen>" screen
  When I touch "Avatar" icon
  Then I should see "Camera View" screen
  | screen           |
  | Sign Up          |
#  | User Information |

@Flips-5
Scenario: Cheking items on Camera View screen
  Given I am on the "<screen>" screen
  When I go to "Camera View" screen
  Then I should see a front facing camera
  And I should see a dark opaque circular mask on the camera
  And I should see "Yellow" button
  And I should see "Photos" icon
  And I should see "Rotate" option enable
  And I should see "Flash" option disable
  | screen           |
  | Sign Up          |
#  | User Information |

@7174 @Flips-5
Scenario: Touching Back button
  Given I am on the "<screen>"
  And I go to "Camera View" screen
  When I touch "Back" button
  Then I should see "<screen>" screen
  | screen           |
  | Sign Up          |
#  | User Information |

@7174 @7617 @7455 @Flips-5
Scenario: Rotate from front-facing to back camera
  Given I am on the "<screen>" screen
  And the camera is in front-facing
  When I touch "Rotate" option
  Then I should see an animation
  And After that I should see back camera
  And I should see "Flash" button enable and with the last option selected
  | screen      |
  | Camera View |
# | Compose     |

@7174 @7455 @Flips-5
Scenario: Turn Flash from off to on
  Given I am on the "<screen>" screen
  And The camera is rotate back
  And the flash is off
  When I touch "Flash" button
  Then The flash should change to on
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @7455 @Flips-5
Scenario: Turn flash from on to auto
  Given I am on the "<screen>" screen
  And The camera is rotate back
  And the flash is on
  When I touch "Flash" button
  Then The flash should change to auto
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @7455 @Flips-5
Scenario: Turn Flash from on to off
  Given I am on the "<screen>" screen
  And the camera is rotate back
  And the flash is on
  When I touch "Flash" button
  Then the flash should change to off
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @7455 @Flips-5
Scenario: Rotate from back camera to front-facing
  Given I am on the "<screen>" screen
  And the camera is rotate back
  When I touch "Rotate" button
  Then I should see an animation
  And After that I should see front-facing camera
  And I should see "Flash" button disable
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @Flips-5
Scenario: Verifying title screen
  Given I am on the "Camera View" screen
  Then I should see "Take Picture" as a title

@7174 @Flips-5
Scenario: Verifying design screen
  Given I am on the "Camera View" screen
  Then The desing screen should be the same on the prototype design
