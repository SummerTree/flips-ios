Feature: Facebook access
  As an user
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
  And I touch "Don't Allow" option on the message
  Then I should see "Login" screen
  And The fields should keep filled

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
Scenario: I am log in on facebook again
  Given I am on the "Login" screen
  And I already loged in with facebook account
  When I touch "Login with Facebook" button
  Then I should see "Onboarding" screen

@7169
Scenario: I am log in on facebook for the first time and I'm not 13 years old
  Given I am on the facebook's message accept
  And My facebook's user is 12 years 364 days years old
  When I touch "OK" option
  Then I should see the message: "You must be at least 13 years old to use MugChat."
  And I should see "Login" screen

@7169
Scenario: I am log in on facebook for the first time and I'm 13 years old
  Given I am on the facebook's message accept
  And My facebook's user is exactly 13 years old
  When I touch "OK" option
  Then I should see "Phone Number" screen

@7169
Scenario: I am log in on facebook for the first time and my user doesn't have a profile photo
  Given I am on the facebook's message accept
  And My facebook's user does not have a profile photo
  When I touch "OK" option
  Then I should see "Phone Number" screen

@7169
Scenario: I am log in on facebook for the first time and my user doesn't have a friends list
  Given I am on the facebook's message accept
  And My facebook's user does not have a friends list
  When I touch "OK" option
  Then I should see "Phone Number" screen

@7169
Scenario: Log in on facebook when I deleted all of my friends
  Given I already loged in with facebook
  And I deleted my friends on facebook
  When I log in again on the app with facebook account
  Then I should see "Onboarding" screen

@7169
Scenario: Log in on facebook when I deleted my profile photo
  Given I already loged in with facebook
  And I deleted my profile photo on facebook
  When I log in again on the app with facebook account
  Then I should see "Onboarding" screen
