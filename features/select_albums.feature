Scenario: Seeing Albums icon when I have albums and pictures on my device
  Given I am on the "Join Recorder" screen
  When I have Albums and pictures on my devide
  Then I should see "Albums" icon

Scenario: Touching Albums icon
  Given I am on the "Join Recorder" screen
  When I touch "Albums" icon
  Then I should see "Select Albums" screen
  And the title: Albums

Scenario: Seeing my albums
  Given I am on the "Select Albums" screen
  Then I should see all albums on my device

Scenario: Seeing my photos
  Given I am on the "Select Albums" screen
  When I touch an album
  Then I should see all pictures on my album

Scenario: Touching Back button on selecting picture screen
  Given I am on the "Select Picture" screen
  When I touch "Back" button
  Then I should see "Select Albums" screen
