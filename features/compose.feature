Feature: Compose Screen
  As a user
  I want to send word, photos and videos to my friends
  So, I can type a word and connect it with a video or photo

@7448
Scenario: Access Compose screen
  Given I am on the "View Mug" screen
  When I write a reply
  And I touch "Next" button
  Then I should see "Compose" screen
  And The first word should be selected

@7448
Scenario: Showing words
  Given I am on the "Compose" screen
  Then I should see all words that I typed on the previous screen

@7448
Scenario: Words that have photos available on the user's dictionary
  Given I am on the "Compose" screen
  When There are photos available on the user's dictionary
  Then I should see "..." icon on the top of word

@7448
Scenario: Words that have videos available on the user's dictionary
  Given I am on the "Compose" screen
  When There are videos available on the user's dictionary
  Then I should see "..." icon on the top of word

@7448
Scenario: Words that have photos available on the Stok Mug
  Given I am on the "Compose" screen
  When There are photos available on the Stok Mugs
  Then I should see "..." icon on the top of word

@7448
Scenario: Words that have videos available on the Stok Mugs
  Given I am on the "Compose" screen
  When There are videos available on the Stok Mugs
  Then I should see "..." icon on the top of word

@7448
Scenario: Words that do not have videos or photos available on the user's distionary or Stok Mugs option
  Given I am on the "Compose" screen
  When There are not videos or photos available on the user's dictionary or Stok Mugs option
  Then I shouldn't see "..." icon on the top of word

@7448
Scenario: Words that are assigned
  Given I am on the "Compose" screen
  When The word is assigned
  Then I should see the word within a green filled circle

@7448
Scenario: Words that are not assigned
  Given I am on the "Compose" screen
  When The word is not assigned
  Then I should see the word within only a green circle

@7448
Scenario: Seeing Punctuation on Compose screen
  Given I am on the "Compose" screen
  When I have strings like: "." or ";" or "!!!"
  Then I should see each of these strings between "" as one word

@7448
Scenario: Updating a text
  Given I am on the "Compose" screen
  And I touch "Back" button
  When I update the text
  And I go to "Compose" screen
  Then I should see the words updated

@7448
Scenario: Selecting other words
  Given I am on the "Compose" screen
  And I don't have a video or photo to any word
  When I touch a word didn't select automatically
  Then I should see the this word selected
  And I should see the word selected automatically deselected  

@7447
Scenario: Showing joined words
  Given I am on the "Compose" screen
  When I have a joined word
  Then I should see both words in only one group of words

@7447
Scenario: Spliting words
  Given I am on the "Compose" screen
  When I have a word joined
  And I touch it
  Then I should see "Split" option

@7447
Scenario: Showing split words
  Given I am seeing "Split" option
  When I touch it
  Then I should see 2 words

@7449
Scenario: Swiping words to the right
  Given I am on the "Compose" screen
  When I swipe the words to the right
  Then I should see the first words

@7449
Scenario: Swiping words to the left
  Given I am on the "Compose" screen
  When I swipe the words to the left
  Then I should see the last words

@7449
Scenario: Swiping words when the word is not snap on the center
  Given I am on the "Compose" screen
  When I swipe the words
  And I position a word not in the center of the line
  Then The word should automatically aligned in the center

@7450
Scenario: Compose screen when the word selected doesn't have previous mugs available
  Given I am on the "Compose" screen
  When I select a word that doesn't have previous mugs available
  Then I should see: "Available Mugs" icon on the left, "Yellow" button on the middle, "Photo" icon on the right
  And Above the words I should see front-facing camera view

@7450
Scenario: Compose screen when the word selected has previous mugs available from user's dictionary
  Given I am on the "Compose" screen
  When I select a word that has previous mugs available from user's dictionary
  But Doesn't have previous mugs available from Stock Mugs
  Then I should see: "My Mugs" string, "Stock Mugs" string, "+" button and user's dictionary image from this word
  And Above the words I should see a green background

@7450
Scenario: Compose screen when the word selected has previous mugs available from Stock Mug
  Given I am on the "Compose" screen
  When I select a word that has previous mugs available from Stock Mug
  But Does not have previous mugs available from user's dictionary
  Then I should see: "My Mugs" string, "Stock Mugs" string, "+" button and user's dictionary image from this word
  And Above the words I should see a green background

@7450
Scenario: Compose screen when the word selected has previous mugs available from Stock Mug and user's dictionary
  Given I am on the "Compose" screen
  When I select a word that has previous mugs available from Stock Mug
  And This word has previous mugs available from user's dictionary
  Then I should see: "My Mugs" string, "Stock Mugs" string, "+" button and user's dictionary image from this word
  And Above the words I should see a green background

@7450
Scenario: Touching My Mugs/Stock Mugs image
  Given I am on the "Compose" screen
  And I selected a word that has previous mugs available
  When I touch a image on the My Mugs/Stock Mugs list
  Then I should see this image above the words
  And I should see a check on the image

@7450
Scenario: Deselectiong a mug on the My Mugs/Stock Mugs list
  Given I am on the "Compose" screen
  And I have a My Mugs/Stock Mugs selected
  When I touch this image
  Then I should see this image desalected
  And I should see a green background above the words

@7450
Scenario: Touching Available Mugs icon when the word selected doesn't have available mugs
  Given I am on the "Compose" screen
  And I selected a word without available mugs
  When I touch "Available Mugs" icon
  Then I shouldn't see: "Available Mugs" icon, "Yellow" button, "Photo" icon
  And I should see: "My Mugs" string, "Stock Mugs" string, "+" button

@7450
Scenario: Touching + icon
  Given I am on the "Compose" screen
  And I selected a word with available mugs
  When I touch "+" icon
  Then I shouldn't see: "My Mugs" string, "Stock Mugs" string, "+" button
  And I should see: "Available Mugs" icon, "Yellow" button, "Photo" icon

@7450
Scenario: Touching a word with no available mugs after selecting a word with available mugs
  Given I am on the "Compose" screen
  And I selected a word with available mugs
  When I touch another word with no available mugs
  Then I shouldn't see: "My Mugs" string, "Stock Mugs" string, "+" button
  And I should see: "Available Mugs" icon, "Yellow" button, "Photo" icon

@7450
Scenario: Touching a word with available mugs after selecting a word with no available mugs
  Given I am on the "Compose" screen
  And I selected a word with no available mugs
  When I touch another word with available mugs
  Then I shouldn't see: "Available Mugs" icon, "Yellow" button, "Photo" icon
  And I should see: "My Mugs" string, "Stock Mugs" string, "+" button

@7451
Scenario: Touching yellow button
  Given I am on the "Compose" screen
  And I selected a word without available mugs
  When I touch "Yellow" button
  Then A photo should be taken
  And I should see "Microphone" screen

@7451
Scenario: Selecting a photo on camera roll
  Given I am on the "Compose" screen
  When I select a picture on the camera roll
  Then I should see "Microphone" screen

@7451
Scenario: Selecting a photo on My Mugs/Stock Mugs
  Given I am on the "Compose" screen
  When I select a picture on My Mugs/Stock Mugs list
  Then I should see "Microphone" screen

@7452
Scenario: Holding yellow button for 1 second
  Given I am on the "Compose" screen
  And I selected a word without available mugs
  When I hold "Yellow" button for 1 second
  Then A video should be recorded with 1 second
  And I should see "Confirm Photo" screen

@7452
Scenario: Holding yellow button for more than 1 second
  Given I am on the "Compose" screen
  And I selected a word without available mugs
  When I hold "Yellow" button for 4 seconds
  Then A video should be recorded with 1 second
  And I should see "Confirm Photo" screen

@7452
Scenario: Seeing progress bar
  Given I am on the "Compose" screen
  And I selected a word without available mugs
  When I hold "Yellow" button
  Then I should see a progress bar across the top of the frame

Scenario: Showing Message when is MugBoys mug
  Given I am on the "Compose" screen
  When The mug selected is MugBoys mug
  Then I should see the message: "This is where the magic happens. Tap the + to record the first word."

Scenario: Showing Message when is not MugBoys mug
  Given I am on the "Compose" screen
  When The mug selected is not MugBoys mug
  Then I shouldn't see the message: "This is where the magic happens. Tap the + to record the first word."

@7448
Scenario: Touching Back button
  Given I am on the "Compose" screen
  When I touch "Back" button
  Then I should see "View Mug" screen
  And I should see what I typed before

@7448
Scenario: Verifying title screen when the mug has only one person
  Given I am on the "Compose" screen
  When I have a mug with only one person
  Then I should see person's name who send me the mug as a title

@7448
Scenario: Verifying title screen when the mug has more than one person
  Given I am on the "Compose" screen
  When I have a mug with only more than one person
  Then I should see "Group Chat" as a title

@7448
Scenario: Verifying design screen
  Given I am on the "Compose" screen
  Then The desing screen should be the same on the prototype design
