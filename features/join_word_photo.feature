Feature: Joining the word with a video or photo
  As a user
  I want to send word, photos and videos to my friends
  So, I can type a word and connect it with a video or photo

Scenario: Access Join Word Photo screen
  Given I am on the "View Mug" screen
  When I write a reply
  And I touch "Next" button
  Then I should see "Join Word Photo" screen
  And The first word should be selected

Scenario: Showing words
  Given I am on the "Join Word Photo" screen
  Then I should see all words that I typed on the previous screen

Scenario: Showing joined words
  Given I am on the "Join Word Photo" screen
  When I have a joined word
  Then I should see both words in only one group of words

Scenario: Touching Back button
  Given I am on the "Join Word Photo" screen
  When I touch "Back" button
  Then I should see "View Mug" screen
  And I should see what I typed before

Scenario: Updating a text
  Given I am on the "Join Word Photo" screen
  And I touch "Back" button
  When I update the text
  And I go to "Join_Word_Photo" screen
  Then I should see the words updated

#esperar resposta do Ben
Scenario: Touching Preview button when I don't have imges/videos joining my words
  Given I am on the "Join Word Photo" screen
  And I don't have photos joining my words
  When I touch "Preview" button
  Then I should see a preview about my words and videos

Scenario: Touching Preview button when I have imges/videos joining my words
  Given I am on the "Join Word Photo" screen
  And I have photos joining my words
  When I touch "Preview" button
  Then I should see a preview about my words and videos

#Aguardar resposta do Ben pra complementar
Scenario: Touching Stock Mugs when the selected word is on the stock mug
  Given I am on the "Join Word Photo" screen
  And I have a word selected that is in stock mug
  When I touch "Stock Mug" option
  Then I should see "Stock Mug" screen

#Aguardar resposta do Ben pra complementar
Scenario: Touching Stock Mugs when the selected word isn't on the stock mug
  Given I am on the "Join Word Photo" screen
  And I have a word selected that isn't in stock mug
  When I touch "Stock Mug" option
  Then I should see "Stock Mug" screen

#Aguardar resposta do Ben pra complementar
Scenario: Viewing my mugs when there are other mugs
  Given I am on the "Join Word Photo" screen
  When I have mugs on my dictionary for all words typed
  And I touch the words
  Then My mugs should update as the selected word

#Aguardar resposta do Ben pra complementar
Scenario: Viewing my mugs when there aren't other mugs
  Given I am on the "Join Word Photo" screen
  When I don't have mugs on my dictionary for all words typed
  And I touch the words
  Then My mugs should show nothing

#Aguardar resposta do Ben pra complementar
Scenario: Touching an existent mug
  Given I am on the "Join Word Photo" screen
  And I have a selected word that has mugs seted up
  When I touch a mug on my mugs
  Then ???

Scenario: Words that already have a mug
  Given I am on the "Join Word Photo" screen
  When The word already has another mug
  Then I should see "..." icon on the top of word

Scenario: Words that don't have a mug
  Given I am on the "Join Word Photo" screen
  When The word doesn't hahave another mug
  Then I shouldn't see "..." icon on the top of word

Scenario: Selecting a video/photo
  Given I am on the "Join Word Photo" screen
  When I select a video/photo to a word
  Then I should see a video/photo selected
  And I should see the word selected

Scenario: After selected a video/photo
  Given I am on the "Join Word Photo" screen
  When I have a selected video/photo to a word
  Then I should see this word with a green background
  And I should see the next word selected

Scenario: Touching Plus button
  Given I am on the "Join Word Photo" screen
  When I touch "Plus" button
  Then I should see "Join Recorder" screen

Scenario: re-recorder a video/photo
  Given I am on the "Join Word Photo" screen
  And I already have a photo/video selected
  When I recorder another photo/video
  Then I should see this new photo/video

#Aguardar a resposta do Ben
Scenario: Selecting Love picture before I picture
  Given I am on the "Join Word Photo" screen
  And I don't have a video or photo to word I
  When I touch word "Love"
  And I select a video or photo
  Then ??

Scenario: Don't selecting a word
  Given I am on the "Join Word Photo" screen
  When I try don't have any word selected
  Then I should not can
