Feature: Phone Number
  As an user
  I want to register my phone number
  So, I can access my friend's photos and videos


Scenario: Seeing Forgot Password screen
  Given I am on the "Register" screen
  When I fill all fields with valid values
  And I touch "Next" button
  Then I should see "Phone Number" screen

Scenario: Informing 9 numbers
  Given I am on the "Phone Number" screen
  When I type 9 numbers
  Then I shouldn't see "Verify Code" screen

Scenario: Informing a wrong code
  Given I am on the "Phone Number" screen
  When I type a invalid phone number
  Then I should see "Verify Code" screen
  And I shouldn't receive the message

Scenario: Informing a right code
  Given I am on the "Phone Number" screen
  When I type a valid phone number
  Then I should see "Verify Code" screen
  And I should receive the message

Scenario: Forgot password by iPod
  Given I am access MugChat on my iPod
  And I am on the "Phone Number" screen
  When I type my cellphone number
  Then I should receive the code on my cellphone

Scenario: Forgot password by another cellphone
  Given I am access MugChat on my cellphone
  And I am on the "Phone Number" screen
  When I type  my cellphone number's friend
  Then I should receive the code on my cellphone's friend

Scenario: Informing a code received on my cellphone's friend
  Given I am on my cellphone
  And I receive a code on my cellphone's friend
  When I put this code on my cellphone
  Then I should see "New Password" screen

Scenario: Touching Back button on Forgot password screen
  Given I am on the "Phone Number" screen
  When I touch "Back" button
  Then I should see "Login" screen
