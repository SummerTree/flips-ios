Feature: Confirm avatar taken or chosen
  As a user
  I want take photos and choose if the photo is good
  So, I can confirm ou reject the photo taked

@7174 @ok @Flips-5
Scenario: Access Confirm Flips screen
  Given I am on the "<screen>" screen
  When I touch "Yellow" icon
  Then I should see "Confirm Flips" screen
  | screen      |
  | Camera View |
#  | Compose     |

@Flips-5
Scenario: Checking itens on Confirm Flip screen
  Given I am on the "Confirm Flips" screen
  Then I should see a white background mask around the photo's border
  And I should see "X" and "√" buttons

@7174 @7456 @ok @Flips-5
Scenario: Rejecting a picture
  Given I am on the "<screen>" screen
  And I go to "Confirm Flips" screen
  When I touch "X" icon
  Then I should see "<screen>" screen
  And The picture or video shouldn't be saved
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @ok @Flips-5
Scenario: Accepting a picture through Camera View screen
  Given I am on the "Camera View" screen
  And I go to "Confirm Flips" screen
  When I touch "√" icon
  Then I should see "Sign Up" screen
  And I should see the photo on the avatar

@Flips-5
Scenario: Touching the picture on the Confirm screen
  Given I am on the "<screen>" screen
  And I go to "Confirm Flips" screen
  When I touch the picture area(picture or white place)
  Then Nothing should happen
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @Flips-5
Scenario: Verifying title screen
  Given I am on the "<screen>" screen
  And I go to "Confirm Flips" screen
  Then I should see "<title>" as a title
  | screen  | title            |
  | Sign Up | Confirm Picture  |
#  | Compose | <contact's name> |

@7174 @ok @Flips-5
Scenario: Verifying design screen
  Given I am on the "Confirm Flips" screen
  Then The desing screen should be the same on the prototype design

#@7456 @ok
#Scenario: Accepting a picture/video through Compose screen and when this word is not the last one on the phrase
#  Given I am on the "Compose" screen
#  And The word selected is not the last word on the phrase
#  And I go to "Confirm Flips" screen
#  When I touch "√" icon
#  Then I should see "Compose" screen
#  And I should see the word selected before filled with a solid green circle
#  And I should see the next word on the phrase selected

#@7456 @Nok
#Scenario: Accepting a picture/video through Compose screen and when this word is the last one on the phrase
#  Given I am on the "Compose" screen
#  And The word selected is the last word on the phrase
#  And I go to "Confirm Flips" screen
#  When I touch "√" icon
#  Then I should see "Preview" screen

#@7456 @ok
#Scenario: Open Confirm Flips screen when there is a record
#  Given I am on the "Compose" screen
#  And I have a "<record>" recorded
#  When I go to "Confirm Flips" screen
#  Then I should see the video in auto-play on loop with a 1-second delay in between
#  | record |
#  | video  |
#  | audio  |

#@7456 @ok
#Scenario: Touching the frame when the record is playing
#  Given I am on the "Confirm Flips" screen
#  And A "<record>" record is playing
#  When I touch the frame
#  Then The record should pause
#  | record |
#  | video  |
#  | audio  |

#@7456 @ok
#Scenario: Touching frame when the record is paused
#  Given I am on the "Confirm Flips" screen
#  And A "<record>" record is paused
#  When I touch the frame
#  Then The record should play where it left off
#  | record |
#  | video  |
#  | audio  |

#@7456 @ok
#Scenario: Open Confirm Flips screen when there is no record
#  Given I am on the "Compose" screen
#  And I don't have a video or audio record
#  When I go to "Confirm Flips" screen
#  Then I should see the picture
#  And I shouldn't see the picture reload
