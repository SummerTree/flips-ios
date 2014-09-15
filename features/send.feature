Scenario: Confirming the last image/video/voice
  Given I am on the "Confirm" screen
  When This is the last word in my phrase
  And I touch "V" icon
  Then I should see "Send" screen
  And The mug should starts to play

Scenario: Touching Back button
  Given I am on the "Send" screen
  When I touch "Back" button
  Then I should see "Join Word Photo" screen

Scenario: Updating the mug
  Given I am on the "Send" screen
  When I touch "Back" button
  And I make changes on my mugs
  And I confirm these changes
  Then I should see "Send" screen
  And These changes on my mug

Scenario: Sending the mug
  Given I am on the "Send" screen
  When I touch "Send" button
  Then I should see "View Mug" screen
  And I should see my mug with my local time
  And I should see my profile photo
  And I should see my phrase
  And I should see "Update Contacts" screen
