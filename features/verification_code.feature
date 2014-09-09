Feature: Verification Code
  As an user
  I want to be security to change my password
  So I the send me a code to change my password


Scenario: Access Verify code screen by Forgot Password
  Given I am on the "Forgot Password" screen
  When I type 10 numbers
  Then I should see "Verify Code" screen

Scenario: Access Verify code screen by Phone Number
  Given I am on the "Phone Number" screen
  When I type 10 numbers
  Then I should see "Verify Code" screen

Scenario: Touching Resend Code without code typed
  Given I am on the "Verification Code" screen
  When Don't type the code
  And I touch "Resend Code" button
  Then I should receive another verification code

Scenario: Touching Resend when the code is wrong
  Given I am on the "Verification Code" screen
  When I type a wrong code
  Then I should see a black background on the code
  And I should see "!" icon

Scenario: Resend Code when my code is wrong
  Given I am on the "Verification Code" screen
  And I type a wrong code
  When I touch "Resend Code" button
  Then I should receive another verification code

Scenario: Update the wrong code to a right one
  Given I am on the "Verification Code" screen
  And A wrong code is typed
  When I correct the code
  Then The background turns red
  And I shouldn't see "!" icon
