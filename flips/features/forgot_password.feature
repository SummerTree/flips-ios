Feature: Forgot Password
  As a user
  I want to reset my password
  So, If I forget that I can enter with another one

@7172 @Flips-147
Scenario: Seeing Forgot Password screen
  Given I am on the "Login" screen
  And I touch Email or Password fields
  When I touch "Forgot Password" button
  Then I should see "Forgot Password" screen

@7592 @Flips-147
Scenario: Seeing message on the Forgot Password screen
  Given I am on the "Forgot Password" screen
  Then I should see a message: "Enter the phone number below to reset your password."

@7172 @Flips-147
Scenario: Auto-formatted when the user types a number
  Given I am on the "Forgot Password" screen
  When The user taps the number
  Then The field should auto-formatted on this way: "###-###-####"

@7172 @Flips-147
Scenario: Informing 9 numbers
  Given I am on the "Forgot Password" screen
  When I type 9 numbers
  Then I shouldn't see "Verification Code" screen

@7172 @Flips-147
Scenario: Informing a number that is not the number of the email typed on Login screen
  Given I am on the "Login" screen
  And the field "Email" is filled with a valid email
  When I go to "Forgot Password" screen
  And I type a phone number that doesn't match with the email but exists on the data base
  Then I should see "Verification Code" screen
  And I shouldn't receive the message on my cellphone

@Flips-147
Scenario: Informing a number that doesn't exists on the data base
  Given I am on the "Forgot Password" screen
  When I type a number that doesn't exists on the data base
  Then I should see a message: "Invalid Number, Phone Number entered does not match our records. Please try again."

@7172 @Flips-147
Scenario: Informing a right number
  Given I am on the "Forgot Password" screen
  When I type my phone number
  Then I should see "Verification Code" screen
  And I should receive the message

@7172 @Flips-147
Scenario: Forgot password by iPod
  Given I am access Flips on my iPod
  And I am on the "Forgot Password" screen
  When I type my cellphone number
  Then I should receive the code on my cellphone

@7172 @Flips-147
Scenario: Touching Back button on Forgot password screen
  Given I am on the "Forgot Password" screen
  When I touch "Back" button
  Then I should see "Login" screen

@7172 @Flips-147
Scenario: Touching Back button on Verification Code screen
  Given I am on the "Verification Code" screen
  When I touch "Back" button
  Then I should see "Forgot Password" screen
  And I should see the number typed

@Flips-147
Scenario: Changing the number typed for another existent on the data base
  Given I typed a number
  And I go to the "Verification Code" screen
  When I touch "Back" button
  And I change the number to a number that exists on the data base
  Then I should see "Verification Code" screen
  And I should receive a new verification code on the device's number typed

@Flips-147
Scenario: Changing the number typed for one inexistent on the data base
  Given I typed a number
  And I go to the "Verification Code" screen
  When I touch "Back" button
  And I change the number to a number that doesn't exists on the data base
  Then I should see a message: "Invalid Number, Phone Number entered does not match our records. Please try again."

@7172 @Flips-147
Scenario: Verifying title screen
  Given I am on the "Forgot Password" screen
  Then I should see "Forgot Password" as a title

@7172 @Flips-147
Scenario: Verifying design screen
  Given I am on the "Forgot Password" screen
  Then The desing screen should be the same on the prototype design
