Scenario: Access Terms of Use screen
  Given I am on the "Settings" screen
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
