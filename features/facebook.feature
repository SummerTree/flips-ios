Feature: Facebook access
  As a user
  I don't want to register a user
  So, I can login with Facebook account

Scenario: I tap on Facebook Login for the first time and I have an account set up on my cellphone
  Given I am on the "Login" screen
  And I have a facebook account set up on my cellphone
  When I touch "Login with Facebook" button
  Then I should see a message: ""MugChat" would like to access our basic profile info and list of friends."
  And I should see the buttons: "Don't Allow" and "Allow"

Scenario: I agree the access of facebook
  Given I am on the facebook's message accept
  When I touch "Allow" option
  Then I should see "Phone Number" screen

Scenario: I Disagree with the terms at facebook
  Given I am on the facebook's message accept
  When I touch "Don't Allow" option
  Then I should see "Login" screen

Scenario: I tap on Facebook Login for the first time and I haven't an account set up on my cellphone
  Given I am on the "Login" screen
  And I don't have a facebook account set up on my cellphone
  When I touch "Login with Facebook" button
  Then I should see Facebook's login screen

Scenario: I log in at facebook
  Given I am on the Facebook's login screen
  When I fill out the fields and touch Login
  Then I should see a message: ""MugChat" would like to access our basic profile info and list of friends."
  And I should see the buttons: "Don't Allow" and "Allow"

Scenario: I am log in at facebook again
  Given I am on the "Login" screen
  And I already loged in with facebook account
  When I touch "Login with Facebook" button
  Then I should see "Inbox" screen
