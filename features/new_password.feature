Feature: New Password
  As an user
  I want to have a possible to register a new password
  So I can infomr a new password when I forgot mine

Scenario: Touching Resend Code button when the code is right
  Given I am on the "Verification Code" screen
  When I type a right code
  Then I should see "New Password" screen

Scenario: Touching Done without type a new password
  Given I am on the "New Password" screen
  When I don't type a value on "New password" field
  And I touch "Done" button
  Then Should happend nothing

Scenario: Done button when there is a value on new password field
  Given I am on the "New Password" screen
  When I type a value on "New password" field
  Then I should see "Done" button in white collor

Scenario: Invalid Password
  Given I am on the "New Password" screen
  When I fill "New Password" with "<value>"
  And I touch "Done" button
  Then I should see the message: Your password should be 8+ Characters, Mixed Case, 1 Number
  | mugchat8 |
  | mugChatt |
  | 12345678 |
  | mugCha8  |
  | mugChat8 |#same value current password

Scenario: Touching Back button on New Password
  Given I am on the "New Password" screen
  When I touch "Back" button
  Then I should see "Forgot Password" screen
