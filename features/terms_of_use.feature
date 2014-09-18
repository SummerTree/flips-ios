Feature: Terms of use on MugChat
  As a user
  I want to know about terms of use on MugChat
  So, I can understand what I can do or not

Scenario: Access Terms of Use screen by Settings
  Given I am on the "Settings" screen
  When I touch "Terms of Use" option
  Then I should see "Terms of Use" screen

Scenario: Access Terms of Use screen by Login
  Given I am on the "Login" screen
  When I touch "Terms of Use" option
  Then I should see "Terms of Use" screen

Scenario: Touching Back on Terms of Use screen
  Given I am on the "Terms of Use" screen
  When I touch "Back" button
  Then I should see "Settings" screen

Scenario: Scrooling Terms of Use
  Given I am on the "Terms of Use" screen
  When I scrool the screen
  Then I should see the rest of the page

Scenario: Verifying title screen
  Given I am on the "Terms of Use" screen
  Then I should see "Terms of Use" as a title

Scenario: Verifying design screen
  Given I am on the "Terms of Use" screen
  Then The desing screen should be the same on the prototype design
