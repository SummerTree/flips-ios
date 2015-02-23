Feature: New Password
  As a user
  I want to have a possible to register a new password
  So I can infomr a new password when I forgot mine

@7172 @Flips-147
Scenario: Touching Done without type a new password
  Given I am on the "New Password" screen
  When I don't type a value on "New password" field
  Then I should see "Done" button should be disable

@7172 @Flips-147
Scenario: Done button when there is a value on new password field
  Given I am on the "New Password" screen
  When I type a value on "New password" field
  Then I should see "Done" button enable

@7172 @Flips-147
Scenario Outline: Invalid Password
  Given I am on the "New Password" screen
  When I fill "New Password" with "<value>"
  And I touch "Done" button
  Then I should see the message: "Your password should be 8+ Characters, Mixed Case, 1 Number"
  | passwor8 |
  | Password |
  | 12345678 |
  | Passwo8  |

@7172 @Flips-147
Scenario: Informing on the new password the password that I forgot
  Given I am on the "New Password" screen
  When I fill "New Password" with the password that I forgot
  And I touch "Done" button
  Then I should see "Login" screen

@7172 @Flips-147
Scenario: Informing a valid new password
  Given I am on the "New Password" screen
  When I fill "New Password" with a valid password
  And I touch "Done" button
  Then I should see "Login" screen

@7172 @Flips-147
Scenario: Touching Back button on New Password
  Given I am on the "New Password" screen
  When I touch "Back" button
  Then I should see "Forgot Password" screen

@7172 @Flips-147
Scenario: Touching Back button and changing the phone number
  Given I am on the "New Password" screen
  And I touched "Back" button
  When I change the phone number
  Then I should go to "Verification Code" screen

@7172 @Flips-147
Scenario: Verifying title screen
  Given I am on the "New Password" screen
  Then I should see "New Password" as a title

@7172 @Flips-147 @9776
Scenario: Verifying design screen in all devices 
  Given I am on the "New Password" screen
  Then The desing screen should be the same on the prototype design
