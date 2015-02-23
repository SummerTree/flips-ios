Feature: Compose Screen
  As a user
  I want to send word, photos and videos to my friends
  So, I can type a word and connect it with a video or photo

@7448 @ok
Scenario: Access Compose screen
  Given I am on the "View Flip" screen
  When I write a reply
  And I touch "Next" button
  Then I should see "Compose" screen
  And The first word should be selected

@7448 @ok
Scenario: Showing words
  Given I am on the "Compose" screen
  Then The row should contain all words that I typed on the previous screen

@7448 @ok
Scenario: Words that have photos available on the user's dictionary
  Given I am on the "Compose" screen
  When There are photos available on the user's dictionary for some of those words
  Then I should see "..." icon on the top of those words

@7448 @ok
Scenario: Words that have videos available on the user's dictionary
  Given I am on the "Compose" screen
  When There are videos available on the user's dictionary for some of those words
  Then I should see "..." icon on the top of those words

@7448 @ok
Scenario: Words that have photos available on the Stock Flip
  Given I am on the "Compose" screen
  When There are photos available on the Stock Flips for some of those words
  Then I should see "..." icon on the top of those words

@7448 @ok
Scenario: Words that have videos available on the Stock Flips
  Given I am on the "Compose" screen
  When There are videos available on the Stock Flips for some of those words
  Then I should see "..." icon on the top of those words

@7448 @ok
Scenario: Words that do not have videos or photos available on the user's distionary or Stock Flips option
  Given I am on the "Compose" screen
  When There are not videos or photos available on the user's dictionary or Stock Flips option for some of those words
  Then I shouldn't see "..." icon on the top of those words

@7448 @ok
Scenario: Words that are assigned
  Given I am on the "Compose" screen
  When The word is assigned
  Then I should see the word within a green filled circle

@7448 @ok
Scenario: Words that are not assigned
  Given I am on the "Compose" screen
  When The word is not assigned
  Then I should see the word within only a green outline circle

@7448 @Nok
Scenario: Seeing Punctuation on Compose screen
  Given I am on the "Compose" screen
  When I have strings like: "." or ";" or "!!!"
  Then I should see each of these strings between "" as one word

@7448 @ok
Scenario: Seeing space on Compose screen
  Given I am on the "Compose" screen
  When I have a space after each word, including the last one
  Then I shouldn't see the spaces as words

@7448 @ok
Scenario: Updating a text
  Given I am on the "Compose" screen
  And I touch "Back" button
  When I update the text
  And I go to "Compose" screen
  Then I should see the words updated

@7448 @ok
Scenario: Selecting other words
  Given I am on the "Compose" screen
  And I don't have a video or photo to any word
  When I swipe to word that wasn't selected automatically
  Then I should see the this word selected
  And I should see the word selected automatically deselected

@7447 @ok
Scenario: Showing joined words
  Given I am on the "Compose" screen
  When I have a joined word
  Then I should see both words in only one group of words

@7447 @ok
Scenario: Spliting words
  Given I am on the "Compose" screen
  When I have a word joined
  And I touch it
  Then I should see "Split" option

@7447 @ok
Scenario: Showing split words
  Given I am seeing "Split" option
  When I touch it
  Then I should see 2 words

@7449 @nok
Scenario: Swiping words left to right
  Given I am on the "Compose" screen
  When I swipe the words left to right
  Then I should see the first words

@7449 @ok
Scenario: Swiping words right to left
  Given I am on the "Compose" screen
  When I swipe the words right to left
  Then I should see the last words

@7449 @ok
Scenario: Swiping words when the word is not snap on the center
  Given I am on the "Compose" screen
  When I swipe the words
  And I position a word not in the center of the line
  Then The word should automatically aligned in the center

@7450 @ok
Scenario: Compose screen when the word selected doesn't have previous flips available
  Given I am on the "Compose" screen
  When I select a word that doesn't have previous flips available
  Then I should see: "Available Flips" icon on the left, "Yellow" button on the middle, "Photo" icon on the right
  And Above the words I should see front-facing camera view

@7450 @ok
Scenario: Compose screen when the word selected has previous flips available from user's dictionary
  Given I am on the "Compose" screen
  When I select a word that has previous flips available from user's dictionary
  But Doesn't have previous flips available from Stock Flips
  Then I should see: "My Flips" string, "+" button and user's dictionary image from this word
  And Above the words I should see a green background
  And I shouldn't see "Stock Flips" string

@7450 @talktoBen
Scenario: Compose screen when the word selected has previous flips available from Stock Flips
  Given I am on the "Compose" screen
  When I select a word that has previous flips available from Stock Flip
  But Does not have previous flips available from user's dictionary
  Then I should see: "My Flips" string, "Stock Flips" string, "+" button and user's dictionary image from this word
  And Above the words I should see a green background

@7450 @talktoBen
Scenario: Compose screen when the word selected has previous flips available from Stock Flips and user's dictionary
  Given I am on the "Compose" screen
  When I select a word that has previous flips available from Stock Flips
  And This word has previous flips available from user's dictionary
  Then I should see: "My Flips" string, "Stock Flips" string, "+" button and user's dictionary image from this word
  And Above the words I should see a green background

@7450 @ok
Scenario: Touching My Flips/Stock Flips image
  Given I am on the "Compose" screen
  And I selected a word that has previous flips available
  When I touch a image on the My Flips/Stock Flips list
  Then I should see this image above the words
  And I should see a check on the image

@7450 @ok
Scenario: Deselecting a flip on the My Flips/Stock Flips list
  Given I am on the "Compose" screen
  And I have a My Flips/Stock Flips selected
  When I touch this image
  Then I should see this image deselected
  And I should see a green background above the words

@7450 @ok
Scenario: Touching Available Flips icon when the word selected doesn't have available flips
  Given I am on the "Compose" screen
  And I selected a word without available flips
  When I touch "Available Flips" icon
  Then I shouldn't see: "Available Flips" icon, "Yellow" button, "Photo" icon
  And I should see: "My Flips" string, "+" button
  And I shouldn't see "Stock Flips" string

@7450 @ok
Scenario: Touching + icon
  Given I am on the "Compose" screen
  And I selected a word with available flips
  When I touch "+" icon
  Then I shouldn't see: "My Flips" string, "Stock Flips" string, "+" button
  And I should see: "Available Flips" icon, "Yellow" button, "Photo" icon

@7450 @ok
Scenario: Touching a word with no available flips after selecting a word with available flips
  Given I am on the "Compose" screen
  And I selected a word with available flips
  When I touch another word with no available flips
  Then I shouldn't see: "My Flips" string, "Stock Flips" string, "+" button
  And I should see: "Available Flips" icon, "Yellow" button, "Photo" icon

@7450 @ok
Scenario: Touching a word with available flips after selecting a word with no available flips
  Given I am on the "Compose" screen
  And I selected a word with no available flips
  When I touch another word with available flips
  Then I shouldn't see: "Available Flips" icon, "Yellow" button, "Photo" icon
  And I should see: "My Flips" string, "+" button
  And If there are Flips available on the Stock Flips I should see "Stock Flips" string

@7451 @ok
Scenario: Touching yellow button
  Given I am on the "Compose" screen
  And I selected a word without available flips
  When I touch "Yellow" button
  Then A photo should be taken
  And I should see "Microphone" screen

@7451 @ok
Scenario: Selecting a photo on camera roll
  Given I am on the "Compose" screen
  When I select a picture on the camera roll
  Then I should see "Microphone" screen

@7451 @talktoBen
Scenario: Selecting a photo on My Flips/Stock Flips
  Given I am on the "Compose" screen
  When I select a picture on My Flips/Stock Flips list
  Then I should see "Microphone" screen

@7452 @ok
Scenario: Holding yellow button for 1 second
  Given I am on the "Compose" screen
  And I selected a word without available flips
  When I hold "Yellow" button for 1 second
  Then A video should be recorded with 1 second
  And I should see "Confirm Flips" screen

@7452 @ok
Scenario: Holding yellow button for more than 1 second
  Given I am on the "Compose" screen
  And I selected a word without available flips
  When I hold "Yellow" button for 4 seconds
  Then A video should be recorded with 1 second
  And I should see "Confirm Flips" screen

@7452 @ok
Scenario: Seeing progress bar
  Given I am on the "Compose" screen
  And I selected a word without available flips
  When I hold "Yellow" button
  Then I should see a progress bar across the top of the frame

@7448 @Nok
Scenario: Touching Back button
  Given I am on the "Compose" screen
  When I touch "Back" button
  Then I should see "View Flips" screen
  And I should see what I typed before

@7448 @ok
Scenario: Verifying title screen when the conversation has only one person
  Given I am on the "Compose" screen
  When I have a conversation with only one person
  Then I should see person's name who send me the message as a title

@7448 @Nok
Scenario: Verifying title screen when the conversation has more than one person
  Given I am on the "Compose" screen
  When I have a conversation with only more than one person
  Then I should see "Group Chat" as a title

@7448 @ok
Scenario: Verifying design screen
  Given I am on the "Compose" screen
  Then The desing screen should be the same on the prototype design
