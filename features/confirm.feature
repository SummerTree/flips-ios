Feature: Confirm Take Picture
  As an user
  I want take fotos and choose if the photo is good
  So, I can confirm ou reject the photo taked

Scenario: Taking a picture
  Given I am on the "Take Picture" screen
  When I touch "Yellow circle" icon
  Then I should see "Confirm" screen

Scenario: Rejecting a taked picture
  Given I am on the "Confirm" screen
  When I touch "X" icon
  Then I should see "Take Picture" screen

Scenario: Taking another picture after canceling one
  Given I am on the "Take Picture" screen
  And There is a picture already taked
  When I touch "Yellow circle" icon
  Then I should see "Confirm" screen

Scenario: Accepting a taked picture
  Given I am on the "Confirm" screen
  When I touch "V" icon
  Then I should see "Register" screen
  And I should see the selected foto on the photo circle
