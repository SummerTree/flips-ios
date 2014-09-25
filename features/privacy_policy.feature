Feature: Privacy Policy on MugChat
  As an user
  I want to know about Privacy Policy on MugChat
  So, I can understand how my personal data will be used

@7168
Scenario: Access Privacy Policy screen
  Given I am on the "<screen>" screen
  When I touch "Privacy Policy" option
  Then I should see "Privacy Policy" screen
  And The animation should be from right to left
  | screen   |
  | Settings |
  | Login    |

@7168
Scenario: Touching Back on Privacy Policy screen
  Given I am on the "<screen>" screen
  And I go to "Privacy Policy" screen
  When I touch "Back" button
  Then I should see "<screen>" screen
  | screen   |
  | Settings |
  | Login    |

@7168
Scenario: Updating informations
  Given The user changed some information on the "Privacy Policy" screen
  When I see this screen again
  Then I should see these changes

@7168
Scenario: Scrooling Privacy Policy
  Given I am on the "Privacy Policy" screen
  When I scrool the screen
  Then I should see the rest of the page

@7168
Scenario: Verifying title screen
  Given I am on the "Privacy Policy" screen
  Then I should see "Privacy Policy" as a title

@7168
Scenario: Verifying design screen
  Given I am on the "Privacy Policy" screen
  Then The desing screen should be the same on the prototype design
