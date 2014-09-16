Feature: Privacy Policy on MugChat
  As an user
  I want to know about Privacy Policy on MugChat
  So, I can understand how my personal data will be used

Scenario: Access Privacy Policy screen by Settings
  Given I am on the "Settings" screen
  When I touch "Privacy Policy" option
  Then I should see "Privacy Policy" screen

Scenario: Access Privacy Policy screen by Login
  Given I am on the "Login" screen
  When I touch "Privacy Policy" option
  Then I should see "Privacy Policy" screen

Scenario: Touching Back on Privacy Policy screen
  Given I am on the "Privacy Policy" screen
  When I touch "Back" button
  Then I should see "Settings" screen

Scenario: Scrooling Privacy Policy
  Given I am on the "Privacy Policy" screen
  When I scrool the screen
  Then I should see the rest of the page

Scenario: Verifying title screen
  Given I am on the "Privacy Policy" screen
  Then I should see "Privacy Policy" as a title

Scenario: Verifying design screen
  Given I am on the "Privacy Policy" screen
  Then The desing screen should be the same on the prototype design
