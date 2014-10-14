Feature: Album Galery
  As a user
  I don't want to take a photo
  So I can select a photo on my device

@7174 @7454
Scenario: Access Album Galery screen
  Given I am on the "Album" screen
  When I touch an iten
  Then I should see "Album Galery" screen

@7174 @7454
Scenario: Selecting a picture
  Given I am on the "Album Galery" screen
  When I touch a photo
  Then I should see "Confirm Mug" screen

@7174 @7454
Scenario: Touching Back button on Album Galery screen
  Given I am on the "Album Galery" screen
  When I touch "Back" button
  Then I should see "Album" screen

@7174 @7454
Scenario: Touching Cancel button on Album Galery screen
  Given I am on the "<screen>" screen
  And I go to "Album Galery" screen
  When I touch "Cancel" button
  Then I should see "<screen>" screen
  | screen      |
  | Camera View |
  | Compose     |

@7174 @7454
Scenario: Verifying title screen
  Given I am on the "Album Galery" screen
  Then I should see "Camera Roll" as a title

@7174 @7454
Scenario: Verifying design screen
  Given I am on the "Album Galery" screen
  Then The desing screen should be the same on the prototype design
