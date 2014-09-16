Feature: New Mug
  As a user
  I want to send news mugs to my friends
  So I can create a new mug

Scenario: Creating a new Mug
  Given I am on the "Onboarding" screen
  When I touch "pencil" icon
  Then I should see "New Mug" screen

Scenario: Canceling a new mug
  Given I am on the "New Mug" screen
  When I touch "Cancel" button
  Then I should see "Onboarding" screen

Scenario: Verifying contacts from the phone
  Given I am on the "New Mug" screen
  Then I should see all my contacts phone

Scenario: Verifying facebook contacts when I logged in by facebook account
  Given I am on the "New Mug" screen
  And I logged in with my facebook account
  When I search for my facebook friends
  Then I should see them

Scenario: Verifying facebook contacts when I logged in by registering on the app
  Given I am on the "New Mug" screen
  And I logged in registering on the app
  When I search for my facebook friends
  Then I shouldn't see them

Scenario: Seeing my contacts
  Given I am on the "New Mug" screen
  When I have contacts registered on MugChat
  And I have contacts didn't register on MugChat
  Then The contacts registered on MugChat should be on the top of the list
  And I should see my contacts in alphabetical order

Scenario: Next button when I don't have a text typed
  Given I am on the "New Mug" screen
  When I don't type nothig
  Then The "Next" button should be disable

Scenario: Next button when I have a text typed
  Given I am on the "New Mug" screen
  When I type a text
  Then The "Next" button should be enable

Scenario: Creating a new mug
  Given I am on the "New Mug" screen
  When I type a text on the text field
  And I touch "Next" button
  Then I should see "Join Word Photo" screen
  And The first word should be selected

Scenario: Picking up more than one person
  Given I am on the "New Mug" screen
  When I pick a person
  And I pick more one person
  And I do it a lot of times
  Then All people that I picked up should be showed on the field: To

Scenario: Searching a person
  Given I am on the "New Mug" screen
  When I type a string with 2 or 3 characters
  Then I should see on the list just the contacts that containing this string

avatar
2 numbers - shows 2 registers
the same name in low and upper case, or with different last names what will happen?
If I'm logged in with facebook will shows me facebook contacts + cellphone contacts?
The first time that I logged in it will sincronize?

If a mug is sent to a person who doesn't has MugChat, a sms will be sent to this person with the message: Ben sent you a message on MugChat, download it here
When the user download the app, the Ben's message will be showed to the user
Scenario: your friend doesn't have MugChat even you number, what will be showed on the message? Name or number?
