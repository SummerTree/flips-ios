Feature: Preview screen
  As a user
  I want to see a preview of the mug that I'm creating
  So, If I don't like something, I can change it before send it to my friends

@7457
Scenario: Accessing Preview screen when the last word is selected and I select a picture on My Mugs/Stock Mugs option
  Given I am on the "Compose" screen
  And The last word of the phrase is selected
  When I select a picture on My Mugs/Stock Mugs option
  Then I should see "Preview" screen

@7457
Scenario: Accessing Preview screen when the last word is selected and I cancel a recorder audio
  Given I am on the "Compose" screen
  And The last word of the phrase is selected
  When I touch "X" on the "Microphone" screen
  And I confirm it
  Then I should see "Preview" screen

@7457
Scenario: Accessing Preview screen when the last word is selected and I recorder an audio
  Given I am on the "Compose" screen
  And The last word of the phrase is selected
  When I record an audio
  And I confirm it
  Then I should see "Preview" screen

@7457
Scenario: Touching Preview button when I have available mugs to select
  Given I am on the "Compose" screen
  And I am seeing My Mugs/Stock Mugs option
  When I touch "Preview" button
  Then I should see "Preview" screen

@7457
Scenario: Touching Preview button when I don't have available mugs to select
  Given I am on the "Compose" screen
  And I am seeing "Yellow" button
  When I touch "Preview" button
  Then I should see "Preview" screen

@7457
Scenario: Touching Preview button on the Microphone screen when I don't have picture selected
  Given I am on the "Microphone" screen
  And I don't have a picture selected
  When I touch "Preview" button
  Then I should see "Preview" screen
  And The message should starts to play with the green background

@7457
Scenario: Touching Preview button on the Microphone screen when I have picture selected
  Given I am on the "Microphone" screen
  And I have a picture selected
  When I touch "Preview" button
  Then I should see "Preview" screen

@7457
Scenario: Seeing words on the Preview screen
  Given I am on the "Preview" screen
  Then I should see all words reproduced for 1 second
  And I should see the message playing in loop with 1 second between

@7457
Scenario: Pausing the message
  Given I am on the "Preview" screen
  And A message is playing
  When I touch the message
  Then The video should pause

@7457
Scenario: Starting the message
  Given I am on the "Preview" screen
  And A message is paused
  When I touch the message
  Then The video should starts where it left off

@7457
Scenario: Touching Back button
  Given I am on the "<screen1>" screen
  And I go to "Preview" screen
  When I touch "Back" button
  Then I should see "<screen2>" screen
  | screen1     | screen2    |
  | Compose     | Compose    |
  | Confirm Mug | Microphone |
  | Microphone  | Microphone |

@7457
Scenario: Sending the message
  Given I am on the "Preview" screen
  When I touch "Send" button
  Then I should see a progress bar

@7457
Scenario: After sending a message
  Given I sent a message
  When Sending message is finished
  Then I should see "View Mug" screen
  And I should see my message on the bottom of the thread with my local time
  And I should see my profile photo on the bottom and on the right side
  And I should see my phrase on the bottom of the message

@7457
Scenario: Verifying title screen
  Given I am on the "Preview" screen
  Then I should see "Preview" as a title

@7457
Scenario: Verifying design screen
  Given I am on the "Preview" screen
  Then The desing screen should be the same on the prototype design
