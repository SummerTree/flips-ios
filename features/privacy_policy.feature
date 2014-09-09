Scenario: Access Privacy Policy screen
  Given I am on the "Settings" screen
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
