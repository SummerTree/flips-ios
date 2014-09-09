Feature: Onboarding screen
  As an user
  I wanto to recorder videos
  S

Scenario: Valid values
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mug@mail.com"
  And I fill "Password" with the value: "Mugchat1"
  And I touch "Done" button
  Then I should see "Onboarding" screen

Scenario: Valid password
  Given I am on the "New Password" screen
  When I fill "New Password" whit "MugTest1"
  And I touch "Done" button
  Then I should see "Onboarding" screen  
