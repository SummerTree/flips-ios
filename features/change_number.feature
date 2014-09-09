Scenario: Access Change Number screen
  Given I am on the "Settings" scren
  When I touch "Change Number" option
  Then I should see "Change Number" screen

Scenario: Touching Back button
  Given I am on the "Change Number" screen
  When I touch "Back" button
  Then I should see "Settings" screen
