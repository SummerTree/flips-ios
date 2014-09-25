Feature: Facebook access
  As a user
  I don't want to register a user
  So, I can login with Facebook account

@7169
Scenario: I tap on Facebook Login for the first time and I have an account set up on my cellphone
  Given I am on the "Login" screen
  And I have a facebook account set up on my cellphone
  When I touch "Login with Facebook" button
  Then I should see a message: ""MugChat" would like to access our basic profile info and list of friends."
  And I should see the buttons: "Don't Allow" and "OK"

@7169
Scenario: I Disagree with the terms at facebook
  Given I am on the "Login" screen
  And The fields are filled
  When I touch "Login with Facebook" button
  And I touch "Don't Allow" option
  Then I should see "Login" screen
  And The fields should keep filled

@7169
Scenario: My user is 12 years 364 days years old and it's the first time that I am log in
  Given I am on the facebook's message accept
  And My user is 12 years 364 days years old
  When I touch "OK" option on the message
  Then I should see "Login" screen
  And I should see the message: "You must be at least 13 years old to use MugChat."

@7169
Scenario: My user is exactly 13 years old and it's the first time that I am log in
  Given I am on the facebook's message accept
  And My user is exactly 13 years old
  When I touch "OK" option on the message
  Then I should see "Phone Number" screen

@7169
Scenario: I am log in on facebook again
  Given I am on the "Login" screen
  And I already loged in with facebook account
  When I touch "Login with Facebook" button
  Then I should see "Inbox" screen

@7169
Scenario: Log in on Facebook for the first time when my user doesn't have friends list
  Given I am on the facebook's message accept
  And My user doesn't have a friends list
  When I touch "OK" option on the message
  Then I should see "Inbox" screen

@7169
Scenario: Log in on Facebook for the first time when my user doesn't have avatar photo
  Given I am on the facebook's message accept
  And My user doesn't have an avatar photo
  When I touch "OK" option on the message
  Then I should see "Inbox" screen

@7169
Scenario: Log in on Facebook again when I deleted my friends list
  Given I am on the facebook's message accept
  And I already logged in with my user but now I deleted my friends
  When I touch "OK" option on the message
  Then I should see "Inbox" screen

@7169
Scenario: Log in on Facebook again when I deleted my avatar photo
  Given I am on the facebook's message accept
  And I already logged in with my user but now I deleted my avatar photo
  When I touch "OK" option on the message
  Then I should see "Inbox" screen

@7169
Scenario: I tap on Facebook Login for the first time and I haven't an account set up on my cellphone
  Given I am on the "Login" screen
  And I don't have a facebook account set up on my cellphone
  When I touch "Login with Facebook" button
  Then I should see Facebook's login screen

@7169
Scenario: I log in at facebook
  Given I am on the Facebook's login screen
  When I fill out the fields and touch Login
  Then I should see a message: ""MugChat" would like to access our basic profile info and list of friends."
  And I should see the buttons: "Don't Allow" and "OK"

@7169
Scenario: I am log in at facebook again
  Given I am on the "Login" screen
  And I already loged in with facebook account
  When I touch "Login with Facebook" button
  Then I should see "Inbox" screen
