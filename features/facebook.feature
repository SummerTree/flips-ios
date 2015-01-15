Feature: Facebook's behavior
  As a user
  I don't want to register a user
  So, I can login with Facebook account

@9749
Scenario: Login with facebook's account for the first time
  Given I didn't logged in with facebooks account yet
  When I touch "Login with Facebook" button
  Then I should see facebook's permition message: ""Flips" would like to access our basic profile info and list of friends."
  And I should see the buttons: "Don't Allow" and "OK"

@7169 @9749
Scenario: I Disagree with the terms at facebook
  Given I am on the facebook's permission message
  When I touch "Don't Allow" option
  Then I should see "Login" screen

@9749
Scenario: I Disagree with the terms at facebook when username and password fields are filled
  Given I am on the "Login" screen
  And Username and Password fields are filled
  When I touch "Login with Facebook" button
  And I touch "Don't Allow" option on the facebook's permission message
  Then I should see "Login" screen
  And The fields should keep filled

@7169 @9749
Scenario: Logging in with facebook and user is 12 years 364 days years old
  Given I am on the facebook's message accept
  And My user is 12 years 364 days years old
  When I touch "OK" option on the message
  Then I should see "Login" screen
  And I should see the message: "You must be at least 13 years old to use Flips."

@7169 @9749
Scenario: Logging in with facebook and user is exactly 13 years old
  Given I am on the facebook's message accept
  And My user is exactly 13 years old
  When I touch "OK" option on the message
  Then I should see "Register" screen

@7169 @9749
Scenario: I am log in on facebook again
  Given I am on the "Login" screen
  And I already loged in with facebook account
  When I touch "Login with Facebook" button
  Then I should see "Inbox" screen

@7169 @9749
Scenario: Log in on Facebook for the first time when my user doesn't have avatar photo
  Given I am on the facebook's message accept
  And My user doesn't have an avatar photo
  When I touch "OK" option on the message
  Then I should see "Register" screen
  And I should see default photo on avatar picture
  And I should see "Next" button disable

@9749
Scenario: Login with facebook for the first time when the user does not have ou did not allowed some information
  Given I am on the facebook's message accept
  And My user doesn't allowed or have filled fiel <field> on facebook
  When I touch "Ok" option on the message
  Then I should see "Register" screen
  And I should see <field> in blanck
  And I should see the rest of the fields with user's facebook values
  And I should see "Next" button disable
  | field    |
  | Email    |
  | Birthday |

@9749
Scenario: Login with facebook for the first time when the user has all information as need to Sign up screen
  Given I am on the facebook's message accept
  And My user allowed and has filled all facebook's information needed on Sign up screen
  When I touch "Ok" option on the message
  Then I should see "Register" screen
  And I should see all fields filled with facebook's value

@9749
Scenario: Filling missing information
  Given I logged in with facebook's account
  And Are missing information on the "Register" screen
  When I fill this information with valid values
  And I touch "Next" button
  Then I should see "Phone Number" screen

@9749
Scenario: Changing Facebook's information to valid values
  Given I logged in with facebook's account
  And I am on the "Register" screen
  And All fields are filled with facebook's values
  When I change all values to valid values
  And I touch Next button
  Then I should see "Phone Number" screen

@9749
Scenario: Login with Facebook and fill or change to invalid values
  Given I logged in with facebook's account
  And I am on the "Register" screen
  When I change or add field <field> to value <value>
  And I touch out of field <field>
  Then I should see message <message>
  | field    | value            | message                                       |
  | email    | flips.com        | Your email should look like this flip@mail.com |
  | email    | flips@gmail      | Your email should look like this flip@mail.com |
  | birthday | today + 1d       | You must be at least 13 years old             |
  | birthday | today-13years+1d | You must be at least 13 years old             |
  | birthday | today            | You must be at least 13 years old             |

@9749
Scenario: Informing a phone number already existent
  Given I logged in with facebook's account
  And I am on the "Phone Number" screen
  When I fill with a phone number already registered to another user
  Then I should see a message: "This phone number is already used by an existing Flips user"

@9749
Scenario: Checking if facebook's id is filling when log in with facebook
  Given I logged in with facebook's account
  Then I should see facebookID column from User table filled

@9749
Scenario: Checking if facebook's id is not filling when log in without facebook
  Given I logged in without facebook's account
  Then I shouldn't see facebookID column from User table filled

@9749
Scenario: Checking Register fields when I logged in with facebook's account
  Given I logged in with facebook's account
  Then I should see: First Name, Last Name, Email and Birthday fields
  And I shouldn't see Password field

@delete
Scenario: Taking picture when the user doesn't have avatar photo on the facebook account
  Given I am on the facebook's message accept with a user that does not have an avatar photo on the facebook account
  When I go to "Camera View" screen
  And I take a photo
  Then I should see "Phone Number" screen

@7169 @9749
Scenario: Log in on Facebook for the first time when my user doesn't have friends list
  Given I am on the facebook's message accept
  And My user doesn't have a friends list
  When I touch "OK" option on the message
  Then I should see "Register" screen

@ImportContacts
Scenario: Log in on Facebook again when I deleted my friends list
  Given I am on the facebook's message accept
  And I already logged in with my user but now I deleted my friends
  When I touch "OK" option on the message
  Then I should see "Inbox" screen

@IThinkthatwillgivefacebooksavatarjustthefirsttime
Scenario: Log in on Facebook again when I deleted my avatar photo
  Given I am on the facebook's message accept
  And I already logged in with my user but now I deleted my avatar photo
  When I touch "OK" option on the message
  Then I should see "Inbox" screen
  And I should see on my picture profile the photo deleted on facebook

@7169 @9749
Scenario: I tap on Facebook Login for the first time and I haven't an account set up on my cellphone but I have the app installed
  Given I am on the "Login" screen
  And I don't have a facebook account set up on my cellphone
  But I have the app installed
  When I touch "Login with Facebook" button
  Then I should see app Facebook's login screen

@7169 @9749
Scenario: I tap on Facebook Login for the first time and I haven't the app installed but I have an account set up on my cellphone
  Given I am on the "Login" screen
  And I don't have facebook app installed on my device
  But I have an account set up on my cellphone
  When I touch "Login with Facebook" button
  Then I should see web browser Facebook's login screen

@7169  @9749
Scenario: I tap on Facebook Login for the first time and I have an account set up on my cellphone and I have the app installed
  Given I am on the "Login" screen
  And I have a facebook account set up on my cellphone
  And I don't have an account on Flips using Facebook
  When I touch "Login with Facebook" button
  Then

@7169 @9749
Scenario: I tap on Facebook Login for the first time and I haven't the app installed and I have not an account set up on my cellphone
  Given I am on the "Login" screen
  And I don't have facebook app installed on my device
  And I don't  have an account set up on my cellphone
  When I touch "Login with Facebook" button
  Then I should see web browser Facebook's login screen

@9749
Scenario: Settings screen when log in with facebook's account
  Given I logged in with facebook's account
  And My user <option> on her first log in
  When I go to "Settings" screen
  Then I should see all information filled
  And I shouldn't see Password information
  | option                                |
  | changed facebook's information        |
  | had all facebook's information        |
  | completed some facebook's information |

@9749
Scenario: Logging off from facebook's account
  Given I am logged with facebook's account
  When I log off
  Then I should see Login screen
  And I shouldn't see Username and Password fields
  And I should see: "If you're <first name>:" label, "Login with Facebook" button, "Not you?" link

@9749
Scenario: Touching Login with Facebook button after log off
  Given I logged off
  And I am on the "Login" screen
  When I touch "Login with Facebook" button
  Then I should see "Inbox screen"

@9749
Scenario: Touching Not you link after do Log off
  Given I logged off
  And I am on the "Login" screen
  When I touch "Not you?" link
  Then I should not see: "If you're <first name>" and "Not you?"
  And I should see: "Username" and "Password" fields and "Login with Facebook" button

@9749
Scenario: Logging off from facebook's account and Logging in again filling Username and Password fields
  Given I am logged in with Facebook's account
  And I did log off
  And I touched link: "Not you?"
  When I fill username and Password fields with valid values
  Then I should see Inbox screen
