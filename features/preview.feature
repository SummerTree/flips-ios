Feature: Preview screen
  As an user
  I want to see a preview of the mug that I'm creating
  So, If I don't like something, I can change it before send it to my friends

Scenario: Touching Back button
  Given I am on the "Preview" screen
  When I touch "Back" button
  Then I should see "Join Photo" screen

Scenario: Touching OK button
  Given I am on the "Preview" screen
  When I touch "OK" button
  Then I should see "View Mug" screen
  And I should see my mug
  And My mug should be sended to my friends

  
