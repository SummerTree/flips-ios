Feature: Verification Code
  As an user
  I want to be security to change my password
  So I the send me a code to change my password

Scenario: Access Verify code screen by Forgot Password screen
  Given I am on the "Forgot Password" screen
  When I type 10 numbers
  Then I should see "Verify Code" screen

Scenario: Access Verify code screen by Phone Number screen
  Given I am on the "Phone Number" screen
  When I type 10 numbers
  Then I should see "Verify Code" screen

Scenario: Access Verify code screen by Change Number screen
  Given I am on the "Type Number" screen
  When I type a valid phone number
  Then I should see "Verify Code" screen

#Ben, could you verify this scenario? There is not a message on the flow and prototype
Scenario: Typed 3 times the wrong code
  Given I am on the "Phone Number" screen
  When I type the wrong code 3 times
  Then I should see a message: You typed 3 times the wrong code. Touch Resend Code and try again.

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

Scenario: Verifying title screen
  Given I am on the "Verification Code" screen
  Then I should see "Verification Code" as a title

Scenario: Verifying design screen
  Given I am on the "Verification Code" screen
  Then The desing screen should be the same on the prototype design
