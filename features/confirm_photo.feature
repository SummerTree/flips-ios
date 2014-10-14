Feature: Confirm avatar taken or chosen
  As a user
  I want take photos and choose if the photo is good
  So, I can confirm ou reject the photo taked

@7174
Scenario: Access Confirm Photo screen through Camera View screen
  Given I am on the "Camera View" screen
  When I touch "Yellow circle" icon
  Then I should see "Confirm Photo" screen
  And I should see a white background mask instead of dark opaque arround the border

@7456
Scenario: Access Confirm Photo screen through Compose screen
  Given I am on the "Compose" screen
  And I am seeing "Yellow" button
  When I touch or I hold this button for 1 second
  Then I should see "Confirm Photo" screen

@7174 @7456
Scenario: Rejecting a picture
  Given I am on the "<screen>" screen
  And I go to "Confirm Photo" screen
  When I touch "X" icon
  Then I should see "<screen>" screen
  And The picture or video shouldn't be saved
  | screen      |
  | Camera View |
  | Compose     |

@7174
Scenario: Accepting a picture through Camera View screen
  Given I am on the "Camera View" screen
  And I go to "Confirm Photo" screen
  When I touch "√" icon
  Then I should see "Register" screen
  And I should see the photo on the avatar

@7456
Scenario: Accepting a picture/video through Compose screen and when this word is not the last one on the phrase
  Given I am on the "Compose" screen
  And The word selected is not the last word on the phrase
  And I go to "Confirm Photo" screen
  When I touch "√" icon
  Then I should see "Compose" screen
  And I should see the word selected before filled with a solid green circle
  And I should see the next word on the phrase selected

@7456
Scenario: Accepting a picture/video through Compose screen and when this word is the last one on the phrase
  Given I am on the "Compose" screen
  And The word selected is the last word on the phrase
  And I go to "Confirm Photo" screen
  When I touch "√" icon
  Then I should see "Preview" screen

@7456
Scenario: Open Confirm Photo screen when there is a record
  Given I am on the "Compose" screen
  And I have a "<record>" recorded
  When I go to "Confirm Photo" screen
  Then I should see the video in auto-play on loop with a 1-second delay in between
  | record |
  | video  |
  | audio  |

@7456
Scenario: Touching the frame when the record is playing
  Given I am on the "Confirm Photo" screen
  And A "<record>" record is playing
  When I touch the frame
  Then The record should pause
  | record |
  | video  |
  | audio  |

@7456
Scenario: Touching the  frame when the record is paused
  Given I am on the "Confirm Photo" screen
  And A "<record>" record is paused
  When I touch the frame
  Then The record should play where it left off
  | record |
  | video  |
  | audio  |

@7456
Scenario: Open Confirm Photo screen when there is not a record
  Given I am on the "Compose" screen
  And I don't have a video or audio record
  When I go to "Confirm Photo" screen
  Then I should see the picture
  And I shouldn't see the picture reload

@7174
Scenario: Taking another picture after canceling one
  Given I am on the "Camera View" screen
  And There is a picture already taken
  When I touch "Yellow circle" icon
  Then I should see "Confirm Photo" screen

@7174
Scenario: Verifying title screen
  Given I am on the "Confirm Photo" screen
  Then I should see "Confirm Picture" as a title

@7174
Scenario: Verifying design screen
  Given I am on the "Confirm Photo" screen
  Then The desing screen should be the same on the prototype design
