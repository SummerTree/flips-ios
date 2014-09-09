Feature: Camera Roll
  As an user
  I don't want to take a photo
  So I can select a photo on my device

Scenario: Touching an iten on Choose Photo screen
  Given I am on the "Choose Photo" screen
  When I touch an iten
  Then I should see "Camera Roll" screen

Scenario: Selectiong a picture
  Given I am on the "Camera Roll" screen
  When I touch a photo
  Then I should see "Register" screen
  And I should see the selected foto on the photo circle

Scenario: Touching Back button on Camera roll screen
  Given I am on the "Camera Roll" screen
  When I touch "Back" button
  Then I should see "Choose Photo" screen
  
