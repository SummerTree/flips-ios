Feature: Change the number set up on my MugChat
  As an user
  I want to change my number
  So, I can update it on MugChat app

Scenario: Access Change Number screen
  Given I am on the "Settings" scren
  When I touch "Change Number" option
  Then I should see "Change Number" screen

Scenario: Touching Back button
  Given I am on the "Change Number" screen
  When I touch "Back" button
  Then I should see "Settings" screen

Scenario: Verifying title screen
  Given I am on the "Change Number" screen
  Then I should see "Change Number" as a title

Scenario: Verifying design screen
  Given I am on the "Change Number" screen
  Then The desing screen should be the same on the prototype design
  
  
#Are we missing the actual flow of changing the number, or is that elsewhere?
