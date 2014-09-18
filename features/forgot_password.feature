Feature: Forgot Password
  As a user
  I want to reset my password
  So, If I forget that I can enter with another one


Scenario: Seeing Forgot Password screen
  Given I am on the "Login" screen
  When I touch "Forgot Password" button
  Then I should see "Forgot Password" screen

Scenario: Informing 9 numbers
  Given I am on the "Forgot Password" screen
  When I type 9 numbers
  Then I shouldn't see "Verification Code" screen

Scenario: Informing a wrong number
  Given I am on the "Forgot Password" screen
  When I type an invalid phone number
  Then I should see "Verification Code" screen
  And I shouldn't receive the message

Scenario: Informing a right number
  Given I am on the "Forgot Password" screen
  When I type a valid phone number
  Then I should see "Verification Code" screen
  And I should receive the message

Scenario: Forgot password by iPod
  Given I am access MugChat on my iPod
  And I am on the "Forgot Password" screen
  When I type my cellphone number
  Then I should receive the code on my cellphone

Scenario: Forgot password by another cellphone
  Given I am access MugChat on my cellphone
  And I am on the "Forgot Password" screen
  When I type  my cellphone number's friend
  Then I should receive the code on my cellphone's friend

Scenario: Informing a code received on my cellphone's friend
  Given I am on my cellphone
  And I receive a code on my cellphone's friend
  When I put this code on my cellphone
  Then I should see "New Password" screen

Scenario: Touching Back button on Forgot password screen
  Given I am on the "Forgot Password" screen
  When I touch "Back" button
  Then I should see "Login" screen

Scenario: Touching Back button on Verification Code screen
  Given I am on the "Verification Code" screen
  When I touch "Back" button
  Then I should see "Forgot Password" screen

Scenario: Verifying title screen
  Given I am on the "Forgot Password" screen
  Then I should see "Forgot Password" as a title

Scenario: Verifying design screen
  Given I am on the "Forgot Password" screen
  Then The desing screen should be the same on the prototype design
