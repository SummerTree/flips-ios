Feature: Terms of use on MugChat
  As a user
  I want to know about terms of use on MugChat
  So, I can understand what I can do or not

@7167
Scenario: Access Terms of Use screen
  Given I am on the "<screen>" screen
  When I touch "Terms of Use" option
  Then I should see "Terms of Use" screen
  And The animation should be from right to left
  | screen   |
  | Settings |
  | Login    |

@7167
Scenario: Touching Back on Terms of Use screen
  Given I am on the "<screen>" screen
  And I go to "Terms of Use" screen
  When I touch "Back" button
  Then I should see "<screen>" screen
  | screen   |
  | Settings |
  | Login    |

@7167
Scenario: Updating informations
  Given The user changed some information on the "Terms of Use" screen
  When I see this screen again
  Then I should see these changes

@7167
Scenario: Scrooling Terms of Use
  Given I am on the "Terms of Use" screen
  When I scrool the screen
  Then I should see the rest of the page

@7167
Scenario: Verifying title screen
  Given I am on the "Terms of Use" screen
  Then I should see "Terms of Use" as a title

@7167
Scenario: Verifying design screen
  Given I am on the "Terms of Use" screen
  Then The desing screen should be the same on the prototype design
