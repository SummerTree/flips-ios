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

#Ben, is just it? The word have to has some specific characteristic?
Scenario: Spliting words
  Given I am on the "Join Word Photo" screen
  When I have only one word
  And I touch it
  Then I should see "Split" option

Scenario: Showing split words
  Given I am seeing "Split" option
  When I touch it
  Then I should see 2 words

#Ben, this message will be showed just on MugBoys Chat? Or at first time for any mug?
Scenario: Showing Message when is MugBoys mug
  Given I am on the "Join Word Photo" screen
  When The mug selected is MugBoys mug
  Then I should see the message: "This is where the magic happens. Tap the + to record the first word."

Scenario: Showing Message when is not MugBoys mug
  Given I am on the "Join Word Photo" screen
  When The mug selected is not MugBoys mug
  Then I shouldn't see the message: "This is where the magic happens. Tap the + to record the first word."

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

Scenario: Touching Preview button when I don't have imges/videos joining my words
  Given I am on the "Join Word Photo" screen
  And I don't have photos joining my words
  When I touch "Preview" button
  Then I should see a preview about my words
  And I should see a green background

Scenario: Touching Preview button when I have imges/videos joining my words
  Given I am on the "Join Word Photo" screen
  And I have photos joining my words
  When I touch "Preview" button
  Then I should see a preview about my words and videos/photos

#Ben, will it happen? I didn't find the stok mug screen
Scenario: Touching Stock Mugs when the selected word is on the stock mug
  Given I am on the "Join Word Photo" screen
  And I have a word selected that is in stock mug
  When I touch "Stock Mug" option
  Then I should see "Stock Mug" screen

#Ben, will it happen? I didn't find the stok mug screen
Scenario: Touching Stock Mugs when the selected word isn't on the stock mug
  Given I am on the "Join Word Photo" screen
  And I have a word selected that isn't in stock mug
  When I touch "Stock Mug" option
  Then I should see "Stock Mug" screen

#Ben, Is it right?
Scenario: Viewing my mugs when there are other mugs
  Given I am on the "Join Word Photo" screen
  When I have mugs on my dictionary for all words typed
  And I touch the words
  Then My mugs should update as the selected word

Scenario: Viewing my mugs when there aren't other mugs
  Given I am on the "Join Word Photo" screen
  When I don't have mugs on my dictionary for all words typed
  And I touch the words
  Then My mugs should show nothing

#Ben, what should happen in this scenario?
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
  Then I should see the next word selected
  And I should see this word with a green background

Scenario: Re-recorder a video/photo
  Given I am on the "Join Word Photo" screen
  And I already have a photo/video selected
  When I recorder another photo/video
  Then I should see this new photo/video

#Ben, Should I do it? And send this mug without picture on the word I
Scenario: Selecting Love word before has a picture to word I
  Given I am on the "Join Word Photo" screen
  And I don't have a video or photo to word I
  When I touch word "Love"
  And I select a video or photo
  Then ??

Scenario: Don't selecting a word
  Given I am on the "Join Word Photo" screen
  When I try don't have any word selected
  Then  I should not do it

Scenario: Verifying title screen when the mug has only one person
  Given I am on the "Join Word Photo" screen
  When I have a mug with only one person
  Then I should see person's name who send me the mug as a title

Scenario: Verifying title screen when the mug has more than one person
  Given I am on the "Join Word Photo" screen
  When I have a mug with only more than one person
  Then I should see "Group Chat" as a title

Scenario: Verifying design screen
  Given I am on the "Join Word Photo" screen
  Then The desing screen should be the same on the prototype design
