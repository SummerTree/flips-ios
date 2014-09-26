Feature: New Password
  As a user
  I want to have a possible to register a new password
  So I can infomr a new password when I forgot mine

@7172
Scenario: Touching Done without type a new password
  Given I am on the "New Password" screen
  When I don't type a value on "New password" field
  Then I should see "Done" button should be disable

@7172
Scenario: Done button when there is a value on new password field
  Given I am on the "New Password" screen
  When I type a value on "New password" field
  Then I should see "Done" button enable

@7172
Scenario Outline: Invalid Password
  Given I am on the "New Password" screen
  When I fill "New Password" with "<value>"
  And I touch "Done" button
  Then I should see the message: "Your password should be 8+ Characters, Mixed Case, 1 Number"
  | mugchat8 |
  | mugChatt |
  | 12345678 |
  | mugCha8  |

@7172
Scenario: Informing on the new password the password that I forgot
  Given I am on the "New Password" screen
  When I fill "New Password" whit the password that I forgot
  And I touch "Done" button
  Then I should see "Inbox" screen

@7172
Scenario: Touching Back button on New Password
  Given I am on the "New Password" screen
  When I touch "Back" button
  Then I should see "Forgot Password" screen

@7172
Scenario: Verifying title screen
  Given I am on the "New Password" screen
  Then I should see "New Password" as a title

@7172
Scenario: Verifying design screen
  Given I am on the "New Password" screen
  Then The desing screen should be the same on the prototype design
