Feature: Confirm Take Picture
  As an user
  I want take photos and choose if the photo is good
  So, I can confirm ou reject the photo taked

Scenario: Taking a picture
  Given I am on the "<screen>" screen
  When I touch "Yellow circle" icon
  Then I should see "Confirm" screen
  | screen       |
  | Take Picture |
  | Recorder     |

Scenario: Rejecting a taked picture
  Given I am on the "<screen>" screen
  And I go to "Confirm" screen
  When I touch "X" icon
  Then I should see "<screen>" screen
  | screen       |
  | Take Picture |
  | Recorder     |

Scenario: Taking another picture after canceling one
  Given I am on the "<screen>" screen
  And There is a picture already taken
  When I touch "Yellow circle" icon
  Then I should see "Confirm" screen
  | screen       |
  | Take Picture |
  | Recorder     |

Scenario: Accepting a took picture by Take Picture screen and this is not the last word
  Given I am on the "Microphone" screen
  And I go to "Confirm" screen
  When I touch "V" icon
  Then I should see "Join Word Photo" screen
  And I should see the next word selected

Scenario: Acception a recorder by Recorder screen and this is not the last word
  Given I am on the "Recorder" screen
  And I recorder a video
  When I go to "Confirm" screen
  And I touch "V" icon
  Then I should see "Join Word Photo" screen
  And I should see the next word selected

Scenario: Verifying title screen
  Given I am on the "Confirm" screen
  Then I should see "Confirm Picture" as a title

Scenario: Verifying design screen
  Given I am on the "Confirm" screen
  Then The desing screen should be the same on the prototype design
