Feature: Type number screen
  As a user
  I want to change my phone number
  So, I can type my new number

Scenario: Touching Next button on change number screen
  Given I am on the "Change Number" screen
  When I touch "Next" button
  Then I should see "Type Number" screen

Scenario: Fill New Number with 9 characters
  Given I am on the "Type Number" screen
  When I fill "New Number" with 9 characters
  Then I shouldn't see "Verification Code" screen
  And Nothing should happend

Scenario: Fill New Number with 10 characters
  Given I am on the "Type Number" screen
  When I fill "New Number" with 10 characters
  Then I should see "Verification Code" screen

Scenario: Informing a wrong number
  Given I am on the "Type Number" screen
  When I type an invalid phone number
  Then I should see "Verification Code" screen
  And I shouldn't receive the message

Scenario: Informing a right number
  Given I am on the "Type Number" screen
  When I type a valid phone number
  Then I should receive the message

Scenario: Change Number by iPod
  Given I am access MugChat on my iPod
  And I am on the "Type Number" screen
  When I type other cellphone number
  Then I should receive the code on this cellphone number

Scenario: Change Number by another cellphone
  Given I am access MugChat on my cellphone
  And I am on the "Type Number" screen
  When I type  my cellphone number's friend
  Then I should receive the code on my cellphone's friend

Scenario: Change to the same number
  Given I am on "Type Number" screen
  When I type the Old number on New Number field
  Then I should receive the code
  And Nothing should change

Scenario: Informing a code received on my cellphone's friend
  Given I am on my cellphone
  And I receive a code on my cellphone's friend
  When I put this code on my cellphone
  Then I should see "Settings" screen

Scenario: Touching Back button on Type Number screen
  Given I am on the "Type Number" screen
  When I touch "Back" button
  Then I should see "Change Number" screen

Scenario: Give up to change the number
  Given I am on the "Verification Code" screen
  When I touch "Back" button
  And I receive/invite photos and video
  Then I should be able to do it with my old number

Scenario: Touching back button on Verification Code screen
  Given I am on the "Verification Code" screen
  When I touch "Back" button
  Then I should see "Type Number" screen

Scenario: Verifying title screen
  Given I am on the "Type Number" screen
  Then I should see "Change Number" as a title

Scenario: Verifying design screen
  Given I am on the "Type Number" screen
  Then The desing screen should be the same on the prototype design
