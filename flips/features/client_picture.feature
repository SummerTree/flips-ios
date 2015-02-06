Feature: Accepting Test to Send Pictures between 2 devices
  As a user
  I want to do some tests on send pictures feature to make sure that these features are Ok
  So, I know that it is ready

Scenario: Doing Login
  Given I am on the "Login" screen
  When I fill "Email" with the value: "bruno.brugg@gmail.com"
  And I fill "Password" with the value: "Password1"
  And I touch "Done" button
  Then I should see "Inbox" screen

Scenario: Creating a new Flip
  Given I am on the "Inbox" screen
  When I touch "Pencil" icon
  Then I should see "New Flip" screen
  And I should see "Next" button disabled

Scenario: Searching a contact to send a flip message
  Given I am on the "New Flip" screen
  And I am logged with Bruno's user
  When I type the string "Ca"
  Then I should see on the list "Caio Fonseca" as a contact

Scenario: Touching a contact searched
  Given I am on the "New Flip" screen
  And I'm seeing "Caio Fonseca" as a contact
  When I touch this contact on the list
  Then I should see this contact on the field "To"

Scenario: Writing new message or answering one
  Given I am on the "New Flip" screen
  And I have Caio Fonseca as a contact selected
  When I type a message: "Hi Caio!!!"
  Then I should see "Next" button enable

Scenario: Touching Next button
  Given I am on the "New Flip" screen
  And I have a contact select
  And I have a message: "Hi Caio!!!" typed
  When I touch "Next" button
  Then I should see "Compose" screen
  And I should see word "Hi" selected

Scenario: Taking a Picture to word Hi
  Given I am on the "Compose" screen
  And I have word "Hi" selected
  When I touch "Yellow" button
  Then I should see a picture taked
  And I should see "Microphone" button
  And I should see "Cancel Mic" button

Scenario: Touching "Cance Mic" button
  Given I am on the "Compose" screen
  And I am seeing "Cancel Mic" button
  When I touch it
  Then I should see "Confirm" screen
  And I should see only a picture I shouldn't listen audio

Scenario: Touching X button on Confirm screen
  Given I am on the "Confirm" screen
  When I touch "X" button
  Then I should see "Compose" screen
  And I shouldn't see the picture tooked

Scenario: Touching √ button on Confirm screen
  Given I am on the "Confirm" screen
  When I touch "√" button
  Then I should see "Compose" screen
  And I should see next word selected
  And I should see word "Hi" with a green background
  And I should see "Yellow" button, "Album" icon and "User's dictionary" icon

Scenario: Touching Hi
  Given I am on the "Compose" screen
  And I am seeing "Caio" word selected
  And I already have a picture selected to word "Hi"
  When I touch word "Hi"
  Then I should see "Hi" selected
  And I should see the picture selected to this word
  And I should see "Plus" button and the photo selected with "√" icon

Scenario: Touching !!!
  Given I am on the "Compose" screen
  And The word "Caio" is selected
  And I already have a picture selected to word "Hi"
  And I don't have a picture selected to word "Caio"
  When I touch "!!!"
  Then I should see word "!!!" selected
  And I should see "Yellow" button, "Album" icon and "User's dictionary" icon

Scenario: Selecting a photo from album to word Caio
  Given I am on the "Compose" screen
  And The word "Caio" is selected
  When I touch "Album" icon
  Then I should see all pictures from my camera

Scenario: Touching a photo
  Given I am on the "Album" screen
  When I touch a photo
  Then I should see "Compose" screen
  And I should see the photo selected on Albuns screen
  And I should see "Microphone" button
  And I should see "Cancel Mic" button

Scenario: Recording all words
  Given I am on the "Compose" screen
  And I have images selected to words: "Hi" and "Caio"
  And I don't have image selected to word "!!!"
  When I touch "Preview" button
  Then I should see "Preview" screen
  And I should see Hi and Caio with images
  And I should see !!! with a green background

Scenario: Sending a flip message
  Given I am on the "Preview" screen
  And I am seeing a video with all words and pictures
  When I touch "Send" button
  Then I should "Inbox" screen
  And I should see this message on the inbox screen
  And The message should appear on the inbox screen from Caio's user

Scenario: Receiving a Flip message
  Given I am logged with Caio's account: caio@gmail.com, password: Password1
  When I am on the "Inbox" screen
  Then I should see the first image from the message sent

Scenario: Touching a Flip message received
  Given I am on the "Inbox" screen
  And I am logged with Caio's account
  When I touch this message on the Inbox screen
  Then I should see "View Flip" screen
  And The message should start to play
  And I should see all words with their respective images

Scenario: Touching Chat bubble icon to answer the flip message
  Given I am on the "View Flip" screen
  And I am watching the message send from Bruno
  When I touch "Chat bubble" icon
  Then I should see a text field to type a flip message
