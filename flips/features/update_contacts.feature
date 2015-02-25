Feature: Update contacts list
  As a user
  I want to add new contacts on my cellphone or facebook and I want to see them on Flips
  So, I can send flips to these contacts too

#Ben, what should happen here?
Scenario: Touching Next time
  Given I am on the "Update Contacts" screen
  When I touch "Next time" button
  Then ??

Scenario: Touching Yeah,duh
  Given I am on the "Update Contacts" screen
  And I logged in with registration option
  When I touch "Yeah,duh" button
  Then I should see a message: ""Flips" Would Like to Access your Contact"
  And I should see buttons: "Cancel" and "OK"

#waiting Ben
Scenario: Touching Cancel option
  Given I am seeing the permission message
  When I touch "Cancel" option
  Then I should see ???

#waiting Ben
Scenario: Touching allow option
  Given I am seeing the permission message
  When I touch "OK" option
  Then I should see ???

#Ben, the same message? It will update the contacts with the phone and facebook right?
Scenario: User logged in by facebook
  Given I am on the "Update Contacts" screen
  And I logged in with facebook option
  When I touch "Yeah,duh" button
  Then I should see a message: ""Flips" Would Like to Access your Contact"
  And I should see buttons: "Cancel" and "OK"

Scenario: Verifying design screen
  Given I am on the "Update Contacts" screen
  Then The desing screen should be the same on the prototype design
