Feature: Album Gallery
  As a user
  I don't want to take a photo
  So I can select a photo on my device

@7174 @7454 @Flips-5
Scenario: Access Album Gallery screen
  Given I am on the "Album" screen
  When I touch an item
  Then I should see "Album Gallery" screen

@7174 @7454 @Flips-5
Scenario: Selecting a picture
  Given I am on the "Album Gallery" screen
  When I touch a photo
  Then I should see "Confirm Flip" screen

@7174 @7454 @Flips-5
Scenario: Touching Back button on Album Gallery screen
  Given I am on the "Album Gallery" screen
  When I touch "Back" button
  Then I should see "Album" screen

@7174 @7454 @Flips-5
Scenario: Touching Cancel button on Album Gallery screen
  Given I am on the "<screen>" screen
  And I go to "Album Gallery" screen
  When I touch "Cancel" button
  Then I should see "<screen>" screen
  | screen      |
  | Camera View |
#  | Compose     |

@7174 @7454 @Flips-5
Scenario: Verifying title screen
  Given I am on the "Album Gallery" screen
  Then I should see "<file's name>" as a title

@7174 @7454 @Flips-5
Scenario: Verifying design screen
  Given I am on the "Album Gallery" screen
  Then The desing screen should be the same on the prototype design
