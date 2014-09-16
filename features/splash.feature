Feature: Splash screen
  As an user
  I want to use the app
  So I open the MugChat

Scenario: Seeing Default screen
	Given I am opening the app
	Then I should see the "Default" screen

Scenario:  Seeing Splash screen
	Given I am on the "Default" screen
	When I wait a moment
	Then I should see the "Splash" screen

Scenario: Verifying design screen
  Given I am on the "Splash" screen
  Then The desing screen should be the same on the prototype design
