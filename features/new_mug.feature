Feature: New Flips
  As a user
  I want to send news Flips to my friends
  So I can create a new Flips

@ok
Scenario: Creating a new Flips
  Given I am on the "Inbox" screen
  When I touch "Pencil" icon
  Then I should see "New Flips" screen

@ok
Scenario: Canceling a new Flips
  Given I am on the "New Flips" screen
  When I touch "Cancel" button
  Then I should see "Inbox" screen

@falta
Scenario: Verifying contacts from the phone when I logged in by facebook account
  Given I am on the "New Flips" screen
  And I logged in with my facebook account
  When I search for my contacts friends
  Then I should see all my contacts phone

@falta
Scenario: Verifying facebook contacts when I logged in by facebook account
  Given I am on the "New Flips" screen
  And I logged in with my facebook account
  When I search for my facebook friends
  Then I should see them

@falta
Scenario: Verifying facebook contacts when I logged in by registering on the app
  Given I am on the "New Flips" screen
  And I logged in registering on the app
  When I search for my facebook friends
  Then I shouldn't see them

@Nok
Scenario: Seeing my contacts
  Given I am on the "New Flips" screen
  When I have contacts registered on Flips
  And I have contacts didn't register on Flips
  Then The contacts registered on Flips should be on the top of the list
  And I should see my contacts in alphabetical order by first name
  And I should see the photo picked up on the Flips profile of my friends
  And The contacts that don't have a Flips account have to show their initias in place of a photo

@ok
Scenario: Next button when I don't have a text typed
  Given I am on the "New Flips" screen
  When I don't type nothig
  Then The "Next" button should be disable

@ok
Scenario: Next button when I have a text typed
  Given I am on the "New Flips" screen
  When I type a text
  Then The "Next" button should be enable

@ok
Scenario: Creating a new Flips
  Given I am on the "New Flips" screen
  When I type a text on the text field
  And I touch "Next" button
  Then I should see "Compose" screen
  And The first word should be selected

@ok
Scenario: Picking up more than one person
  Given I am on the "New Flips" screen
  When I pick a person
  And I pick more one person
  And I do it a lot of times
  Then All people that I picked up should be showed on the field: To

@ok
Scenario: Searching a person
  Given I am on the "New Flips" screen
  When I type a string with 2 or 3 characters
  Then I should see on the list just the contacts that containing this string

@ok
Scenario: Seeing the contact list when a person has 2 different numbers
  Given I am on the "New Flips" screen
  When I have a contact with 2 numbers registred
  Then I should see this person twice on the list

@ok
Scenario: Seeing the contact list when a person has just one number but different names
  Given I am on the "New Flips" screen
  When I have a contact with 2 different names
  But The same number
  Then I should see this person twice on the list


Scenario: Sending a Flips to a person who doens't have Flips
  Given I am on the "New Flips" screen
  When I pick up on a list a contact that doesn't have a Flips account
  And This contact doesn't have my number on her/him cellphone
  And I send a Flips message to him/her
  Then The person should receive a SMS with the message: <my name> sent you a message on Flips, download it here!


Scenario: Touching Download it here!
  Given I received a SMS by Flips with the link: Download here!
  When I touch this link
  Then I should see the site to do the download


Scenario: Receiving a Flips after downloaded it
  Given I downloaded the Flips
  Then I should receive my friend's Flips message


Scenario: Sendind a Flips to two or more home numbers
  Given I am on the "New Flips" screen
  And I pick up 2 or more contacts with home numbers
  When I send a Flips to them
  Then I should see a list with the numbers that couldn't be sent

Scenario: Sending the Flips again
  Given I am seeing the list with the numbers that couldn't receive my flips
  When I sent the flips again
  Then I should see the list again

Scenario: Removing numbers from the reject list
  Given I am seeing the reject list
  When I remove a contact
  And I send the flips again
  Then I should see the reject list again without the contact removed

Scenario: Adding cellphone numbers on the reject list
  Given I am seeing the reject list
  When I add a contact with cellphone number on the list
  And I send the Flips again
  Then The cellphone added should receive the Flips
  And I should see the reject list with the contacts with home numbers

Scenario: Adding home numbers on the reject list
  Given I am seeing the reject list
  When I add a contact with home number on the list
  And I send the Flips again
  Then I should see the reject list with the home number added

@ok
Scenario: Verifying title screen
  Given I am on the "New Flips" screen
  Then I should see "New Flips" as a title

@ok
Scenario: Verifying design screen
  Given I am on the "New Flips" screen
  Then The desing screen should be the same on the prototype design
