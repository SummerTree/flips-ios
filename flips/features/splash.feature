Feature: Splash screen
  As a user
  I want to use the app
  So I open the Flips

Scenario: Seeing Default screen
	Given I am opening the app
	Then I should see the "Splash" screen

Scenario: Verifying design screen
  Given I am on the "Splash" screen
  Then The desing screen should be the same on the prototype design
