Scenario: Touching a mug
  Given I am on the "Onboarding" screen
  When I touch a mug on the list
  Then I should see "View Mug" screen

Scenario: Watching an unread mug
  Given I am on the "Onboarding" screen
  When I touch an unread mug on the list
  Then The mug video should start to play
  And I shouldn't see the message sent to me

#este cenario, aguardar o Ben responder pra ver se deve ficar deste jeito ou nao
Scenario: Watching a read mug
  Given I am on the "Onboarding" screen
  When I touch a read mug on the list
  Then The video shouldn't start to play
  And I should see the message sent to me

#este cenario, aguardar o Ben responder pra ver se deve ficar deste jeito ou nao
Scenario: Watching a mug when there is a read and an unread message
  Given I am on the "Onboarding" screen
  When I touch a mug that has a read and an unread message
  Then The mug video for the unread message should start

#este cenario, aguardar o Ben responder pra ver se deve ficar deste jeito ou nao
Scenario: Watching a mug when there is two or more unread messages sent by different people
  Given I am on the "Onboarding" screen
  When I touch a mug that has more than 2 unread messages
  Then I should see the first message sent to me
  And At the end of this message I should see the other message sent to me
  And The photo's person should change according to the message being viewed
  And The time should change according to the message being viewed too

Scenario: Watching a mug in a group
  Given I am on the "View Mug" screen
  When The mug has more than one person
  Then I should see "People list" option

Scenario: Touching People list option
  Given I am on the "View Mug" screen
  And The mug has more than one person
  When I touch "People list" option
  Then I should see all people in these group

Scenario: Miss people list
  Given I am seeing "People list" list
  When I touch "People list" option
  Then I shouldn't see "People list" list

Scenario: Showing words after the mug video
  Given I am watching a mug video
  When The mug video finish
  Then I should see all words on the video

Scenario: Time for each word
  Given I am on the "View Mug" screen
  When I am watching a mug video that has more than one word/photo
  Then I should see each word and photo for 1 seconds

Scenario: Touching Reply button
  Given I am on the "View Mug" screen
  When I touch "Reply" icon
  Then I should see a text field
  And I should see "Next" button disable

Scenario: Writing a message to reply
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write a character
  Then I should see "Next" button enable

#este cenario, aguardar o Ben responder pra ver se deve ficar deste jeito ou nao
Scenario: Writing a message with a lot of characters
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write ?? characters
  And I touch "Next" button
  Then ???

#ver com desenv. se este cenário é possivel e se sim o que acontece
Scenario: Writing a message and I don't have memory
  Given I am on the "View Mug" screen
  And I am seeing the text field to reply a mug
  When I write some words
  And My cellphone's memory finish
  Then ???

Scenario: Showing the time when the message was send from another country
  Given My friend sent a message to me from Brasil
  And In Brasil it's 10am
  When I go to "View Mug"
  And I watch the mug
  Then The time showed should be 6am

#revisar qdo chegar a resposta do Ben
Scenario: Showing user message for the first time watching a message sent by MugBoys
  Given I am on the "View Mug" screen
  When I am watching MugBoys mug
  Then I should see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

#revisar qdo chegar a resposta do Ben
Scenario: Showing user message when the user is replying MugBoys mug
  Given I am on the "View Mug" screen
  And I am watching MugBoys mug
  When I touch "Reply" icon
  Then I should see a purple ballon with the message: Just for fun, lets type I love MugChat

#revisar qdo chegar a resposta do Ben
Scenario: Showing user message for the first time watching a message didn't send by MugChat
  Given I am on the "View Mug" screen
  When I am watching MugBoys mug
  Then I should see a purple ballon with the message: Pretty cool, huh? Now it's your turn.

#revisar qdo chegar a resposta do Ben
Scenario: Showing user message when the user is replying a mug didn't send by MugChat
  Given I am on the "View Mug" screen
  And I am watching MugBoys mug
  When I touch "Reply" icon
  Then I shouldn't see the purple ballon

Scenario: Showing Join option
  Given I am on the "View Mug" screen
  And I am writing San Francisco
  When I select these both words
  Then I should see "Join" option

Scenario: Joining words
  Given I am on the "View Mug" screen
  And I am seeing "Join" option
  When I touch "Join" option
  Then I should see only one word

Scenario: Touching Back button
  Given I am on the "View Mug" screen
  When I touch "Back" button
  Then I should see "Onboarding" screen
