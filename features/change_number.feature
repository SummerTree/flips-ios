Feature: Change the number set up on my MugChat
  As a user
  I want to change my number
  So, I can update it on MugChat app

Scenario: Access Change Number screen
  Given I am on the "Settings" scren
  When I touch "Change Number" option
  Then I should see "Change Number" screen

Scenario: Touching Back button
  Given I am on the "Change Number" screen
  When I touch "Back" button
  Then I should see "Settings" screen

Scenario: Touching Next on the change number screen
  Given I am on the "Change Number" screen
  When I touch "Next" button
  Then I should see "New Number"

Scenario: Informing 9 numbers
  Given I am on the "New Number" screen
  When I type 9 numbers
  Then I shouldn't see "Verification Code" screen

Scenario: Informing a wrong number
  Given I am on the "New Number" screen
  When I type an invalid phone number
  Then I should see "Verification Code" screen
  And I shouldn't receive the message

Scenario: Informing a right number
  Given I am on the "New Number" screen
  When I type a valid phone number
  Then I should see "Verification Code" screen
  And I should receive the message

Scenario: New Number by iPod
  Given I am access MugChat on my iPod
  And I am on the "New Number" screen
  When I type my cellphone number
  Then I should receive the code on my cellphone

Scenario: New Number by another cellphone
  Given I am access MugChat on my cellphone
  And I am on the "New Number" screen
  When I type  my cellphone number's friend
  Then I should receive the code on my cellphone's friend

Scenario: Informing a code received on my cellphone's friend
  Given I am on my cellphone
  And I receive a code on my cellphone's friend
  When I put this code on my cellphone
  Then I should see "New Password" screen

Scenario: Touching Back button on Verification Code screen
  Given I am on the "Verification Code" screen
  When I touch "Back" button
  Then I should see "New Number" screen

Scenario: Verifying title screen
  Given I am on the "Change Number" screen
  Then I should see "Change Number" as a title

Scenario: Verifying design screen
  Given I am on the "Change Number" screen
  Then The desing screen should be the same on the prototype design
