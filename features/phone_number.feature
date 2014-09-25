Feature: Phone Number
  As a user
  I want to register my phone number
  So, I can access my friend's photos and videos

@7173
Scenario: Access Phone Number screen by Register screen
  Given I am on the "Register" screen
  When I fill all fields with valid values
  And I touch "Next" button
  Then I should see "Phone Number" screen

@7173
Scenario: Auto-formatted when the user types a number
  Given I am on the "Phone Number" screen
  When The user taps the number
  Then The field should auto-formatted on this way: ###-###-####

@7173
Scenario: Informing 9 numbers
  Given I am on the "Phone Number" screen
  When I type 9 numbers
  Then I shouldn't see "Verification Code" screen

@7173
Scenario: Informing a wrong number
  Given I am on the "Phone Number" screen
  When I type an invalid phone number
  Then I should see "Verification Code" screen
  And I shouldn't receive the message

@7173
Scenario: Informing a right number
  Given I am on the "Phone Number" screen
  When I type a valid phone number
  Then I should see "Verification Code" screen
  And I should receive the message

@7173
Scenario: Forgot password by iPod
  Given I am access MugChat on my iPod
  And I am on the "Phone Number" screen
  When I type my cellphone number
  Then I should receive the code on my cellphone

@7173
Scenario: Forgot password by another cellphone
  Given I am access MugChat on my cellphone
  And I am on the "Phone Number" screen
  When I type  my cellphone number's friend
  Then I should receive the code on my cellphone's friend

@7173
Scenario: Informing a code received on my cellphone's friend
  Given I am on my cellphone
  And I receive a code on my cellphone's friend
  When I put this code on my cellphone
  Then I should see "New Password" screen

@7173
Scenario: Touching Back button on Forgot password screen
  Given I am on the "Phone Number" screen
  When I touch "Back" button
  Then I should see "Login" screen

@7173
Scenario: Touching Back button on Verification Code screen
  Given I am on the "Verification Code" screen
  When I touch "Back" button
  Then I should see "Phone Number" screen

@7173
Scenario: Verifying title screen
  Given I am on the "Phone Number" screen
  Then I should see "Phone Number" as a title

@7173
Scenario: Verifying design screen
  Given I am on the "Phone Number" screen
  Then The desing screen should be the same on the prototype design
