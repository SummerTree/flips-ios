Feature: Preview screen
  As a user
  I want to see a preview of the mug that I'm creating
  So, If I don't like something, I can change it before send it to my friends

Scenario: Touching Back button
  Given I am on the "<screen>" screen
  And I go to "Preview" screen
  When I touch "Back" button
  Then I should see "<screen>" screen
  | screen          |
  | Join Word Photo |
  | Join Recorder   |
  | Recorder        |

Scenario: Confirming the last image/video/voice
  Given I am on the "Confirm" screen
  When This is the last word in my phrase
  And I touch "V" icon
  Then I should see "Preview" screen
  And The mug should starts to play

Scenario: Updating the mug
  Given I am on the "Preview" screen
  When I touch "Back" button
  And I make changes on my mugs
  And I confirm these changes
  Then I should see "Preview" screen
  And These changes on my mug

Scenario: Sending a mug without video/photos, etc, with green background
  Given I don't have videos/photos/voice on my words
  When I go to "Preview" screen
  Then The mug should starts to play with the green background
  
Scenario: Sending the mug
  Given I am on the "Preview" screen
  When I touch "OK" button
  Then I should see "View Mug" screen
  And I should see my mug with my local time
  And I should see my profile photo
  And I should see my phrase
  And I should see "Update Contacts" screen

Scenario: Verifying title screen
  Given I am on the "Preview" screen
  Then I should see "Preview" as a title

Scenario: Verifying design screen
  Given I am on the "Preview" screen
  Then The desing screen should be the same on the prototype design
