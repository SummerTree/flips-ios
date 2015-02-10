Feature: Register a user
  As a user
  I want to register access Flips
  So I have to register a user

@7170 @Flips-2
Scenario: Access Register screen
  Given I am on the "Login" screen
  When I touch "Sign Up" button
  Then I should see "Sign Up" screen
  And The screen should animate right to left
  And I should see "Forward" button disabled
  And I should see "Back" button enabled

@7170 @Flips-2 @automated
Scenario Outline: Fill only one field
  Given I am on the "Sign Up" screen
  When I fill "<field>" field with the value "<value>"
  Then The button "Forward" should be disable
  Examples:
  | field      | value          |
  | First Name | First          |
  | Last Name  | Last           |
  | Email      | flip@gmail.com |
  | Password   | Passwor8       |
  | Birthday   | 01121987       |

@7170 @Flips-2 @automated
Scenario: Fill all fields with valid values and select a photo
  Given I am on the "Sign Up" screen
  When I fill "First Name" field with the value "First"
  And I fill "Last Name" field with the value "Last"
  And I fill "Email" field with the value "flip@gmail.com"
  And I fill "Password" field with the value "Passwor8"
  And I fill "Birthday" field with the value -13 years old
  And I choose a photo
  And I touch "Forward" button
  Then I should see "Phone Number" screen

@7170 @Flips-2 @9990
Scenario: Fill all fields and don't select a photo
  Given I am on the "Sign Up" screen
  When I fill field "First Name" with the value "First"
  And I fill field "Last Name" with the value "Last"
  And I fill field "Email" with the value "flip@gmail.com"
  And I fill field "Password" with the value "Passwor8"
  And I fill field "Birthday" with the value "<birthday>"
  And I do not choose a photo
  And I touch "Forward" button
  Then I should see a message: "Looks like your photo is missing!"

@7170 @Flips-2
Scenario Outline: Fill with invalid values
  Given I am on the "Sign Up" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "<email>"
  And I fill the field "Password" with "<password>"
  And I fill the field "Birthday" with "<birthday>"
  And I exit the field
  Then I should see an exclamation mark to the right of the field with the invalid value
  And I should see a red error panel sliding down from top of screen with a message: "<message>"
  And The "Forward" button should keep disable
  | email           | password | birthday         | message                                                     |
  | flips.com       | Passwor8 | 12/01/1987       | Your email should look like this flip@mail.com               |
  | flips@gmail     | Passwor8 | 12/01/1987       | Your email should look like this flip@mail.com               |
  | flips@gmail.com | passwor8 | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | flips@gmail.com | Password | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | flips@gmail.com | 12345678 | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | flips@gmail.com | Passwo8  | 12/01/1987       | You must be at least 13 years old                           |
  | flips@gmail.com | Passwor8 | today + 1d       | You must be at least 13 years old                           |
  | flips@gmail.com | Passwor8 | today-13years+1d | You must be at least 13 years old                           |
  | flips@gmail.com | Passwor8 | today            | You must be at least 13 years old                           |

@7170 @Flips-2
Scenario: Fixing wrong values
  Given I am on the "Sign Up" screen
  And I typed a wrong value on "<field>"
  When I fix this value
  And I exit the field
  Then The red error painel with the warning message should dismiss
  | field    |
  | Email    |
  | Password |
  | Birthday |

@7170 @Flips-2
Scenario: Swiping up warning messages panel
  Given I am on the "Sign Up" screen
  And I filled invalid values on the fields
  When I swipe up the warning messages panel
  Then I shouldn't see the panel
  And I should see "Forward" button disabled

@7170 @Flips-2
Scenario: Showing Alpha keyboard
  Given I am on the "Sign Up" screen
  When I touch "<field>" field
  Then I should see "Alpha" keyboard
  | field      |
  | First Name |
  | Last Name  |
  | Password   |

@7170 @Flips-2
Scenario: Showing Email keyboard
  Given I am on the "Sign Up" screen
  When I touch "Email" field
  Then I should see "Email" keyboard

@7170 @Flips-2
Scenario: Birthday value when there is no value
  Given I am on the "Sign Up" screen
  When There is no value on the "Birthday" field
  And The cursor is not in the "Birthday" field
  Then I should see the text: "Birthday"

@Flips-2
Scenario: Touching Birthday field
  Given I am on the "Sign Up" screen
  When I touch "Birthday" field
  Then I should see a barrel picker with Month("January" through "December"), Day (01 - 31), and Year (1900 - current)
  And I should see today as the default selected date(month, day and year)

@Flips-2
Scenario: Touching Done button without select a date
  Given I am on the "Sign Up" screen
  When I touch "Birthday" field
  And I touch "Done" button on the barrel picker
  Then I should see today as a "Birthday" value

@Flips-2
Scenario: Touching another field while I see barrel picker from Birthday field
  Given I am on the "Sign Up" screen
  When I touch "Birthday" field
  And I touch another field
  Then Barrel picker from Birthday field should dismiss

@Flips-2
Scenario: Selecting a date birthday
  Given I am on the "Sign Up" screen
  And I'm seeing barrer picker from Birthday field
  When I select a date
  And I touch "Done" button on the barrel picker
  Then I should see the selected date on the "Birthday" field

@7170 @Flips-2
Scenario: Touching back button
  Given I am on the "Sign Up" screen
  When I touch "Back" button
  Then I should see "Login" screen

@7170 @Flips-2
Scenario: Tapping Back and Sign up again
  Given I am on the "Sign Up" screen
  And All fields are filled
  When I touch "Back" button
  And I touch "Sign Up" again
  Then I should see all fields filled

@7170 @Flips-2
Scenario: Adding a user already added
  Given I am on the "Sign Up" screen
  And I fill all fields with valid values
  And I fill "Email" with a value already added on data base
  When I go to "Phone Number" screen
  And I type a valid number
  Then I should see a message: "An account already exists for that email address. Log in or sign up with a different address."

@7170 @Flips-2
Scenario: Changing the taken photo
  Given I am on the "Sign Up" screen
  And There is a photo already selected
  When I touch the picture
  Then I should be able to change the picture

@Flips-2 @9974
Scenario: It's the first time that I am accessing the app
  Given I never download flips app before
  And I downloaded it now
  When I touch "Sign Up" option
  And I touch "Avatar" icon
  Then I should see a message: "Flips Would Like to Access the Camera", "Don't Allow" button, "Ok" button

@Flips-2 @9974
Scenario: Touching Don't Allow option from permission message
  Given I am seeing camera's permission messagem on "Sign Up" screen
  When I touch "Don't Allow" option
  And I touch some option on photo's permission message
  Then I should see a message: "Flips doesn't have permission to use Camera, please change privacy settings", "Ok" button

@Flips-2 @9974
Scenario: Touching Ok on the camera's permission message
  Given I'm seeing the message to change privacy on the "Sign Up" screen
  When I touch "Ok" option
  Then I should see the circle of the camera black
  And I should see "Rotate" and "Flash" options disabled
  And I should see "Yellow" button disabled

@Flips-2 @9974
Scenario: Touching Allow option from Camera's permission message
  Given I am seeing camera's permission message on "Sign Up" screen
  When I touch "Allow" option
  And I touch some option on photo's permission message
  Then I should see a circle with a front camera
  And I should see "Rotate" and "Flash" option enable
  And I should see "Yellow" button enabled

@Flips-2
Scenario: Allowing Photo's access from Sign Up
  Given I never download flips app before
  And I downloaded it now
  When I touch "Sign Up" option
  And I touch "Avatar" icon
  And I touch any option on Camera's permission message
  Then I should see a message: "Flips Would Like to Access Your Photos", "Don't Allow" button, "Ok" button

@Flips-2
Scenario: Touching Do Not allow option from Photo's permission message
  Given I am seeing photo's permission message on "Sign Up" screen
  When I touch "Don't Allow" option
  Then I should see "Default" icon on photos icon

@Flips-2
Scenario: Touching Photos icon when I did not allow access to photo's device
  Given I did not allow permission to the photo's device
  And I am on the "Sign Up" screen
  And I go to "Take Picture" screen
  When I touch "Photo" icon
  Then I should see a message: "This app does not have access to your photos or videos. You can enable access in Privacy Settings."

@Flips-2
Scenario: Touching Cancel button on Albums screen
  Given I am on the "Sign Up" screen
  And I go to Albums screen
  When I touch "Cancel" button
  Then I should see "Take Picture" screen
  And I shouldn't see the previous camera view before the camera refreshes

@Flips-2
Scenario: Touching Allow option from Photo's permission message
  Given I am seeing photo's permission message on "Sign Up" screen
  When I touch "Allow" option
  Then I should see the last picture took on the albums device

@9531 @9754 @9774 @Flips-2
Scenario: Killing the app before fill Phone Number and try login
  Given I am on the "Sign Up" screen and I filled all fields with valid values
  And I go to "Phone Number" screen
  When I kill the app
  And I Login again with this incomplete user
  Then I should see "!" icon on the right side of "Email" and "Password" fields
  And I should see an alert: "Username or Password incorrect, or account does not exist." button "Ok"

@9531 @9754 @9774 @Flips-2
Scenario: Killing the app after fill Phone Number and try login
  Given I filled all fields with valid values on "Sign Up" and "Phone Number" screens
  And I go to "Verification Code" screen
  When I kill the app
  And I Login again with this incomplete user
  Then I should see "!" icon on the right side of "Email" and "Password" fields
  And I should see an alert: "Username or Password incorrect, or account does not exist." button "Ok"

@9531 @9754 @9774 @Flips-2
Scenario: Touching back button before fill Phone Number and try login
  Given I filled all fields with valid values on "Sign Up" screen
  And I go to "Phone Number" screen
  When I touch "Back" button
  And I try to do login with this incomplete user
  Then I should see "!" icon on the right side of "Email" and "Password" fields
  And I should see an alert: "Username or Password incorrect, or account does not exist." button "Ok"

@9531 @9754 @9774 @Flips-2
Scenario: Touching back button before fill Verification Code and try login
  Given I filled all fields with valid values on "Sign Up" and "Phone Number" screens
  And I go to "Verification Code" screen
  When I touch "Back" button
  And I Login again with this incomplete user
  Then I should see "!" icon on the right side of "Email" and "Password" fields
  And I should see an alert: "Username or Password incorrect, or account does not exist." button "Ok"

@9531 @9754 @9774 @Flips-2
Scenario: Changing phone number to a number not registered on the data base
  Given I filled all fields with valid values on "Sign Up" and "Phone Number" screens
  And I go to "Verification Code" screen
  When I touch "Back" button
  And I change the phone number to a number not registered on the data base yet
  And I go to "Verification Code" screen
  Then I shouldn't see warning message saying that the phone numer or email address is already registered
  And I should can finish my register

@9531 @9754 @9774 @Flips-2
Scenario: Changing phone number to a number already registered on the data base
  Given I filled all fields with valid values on "Sign Up" and "Phone Number" screens
  And I go to "Verification Code" screen
  When I touch "Back" button
  And I change the phone number to a number already registered on the data base
  And I go to "Verification Code" screen
  Then I should see a warning message: "This phone number is already used by an existing Flips user"

@9531 @9754 @9774 @Flips-2
Scenario: Killing the app when I type a number already registered and try to login again
  Given I am seeing the warning message about the phone number already being used
  When I kill the app
  And I try to login again with this incomplete user
  Then I should see "!" icon on the right side of "Email" and "Password" fields
  And I should see an alert: "Username or Password incorrect, or account does not exist." button "Ok"

@Flips-2
Scenario: Touching Ok on the warning message about the phone number already being used
  Given I am seeing the warning message about the phone number already being used
  When I touch "Ok" on the message
  Then I should remain on the "Phone Number" screen

@7170 @Flips-2 @9580 @9990
Scenario: Verifying design
  Given I am on the "Sign Up" screen
  Then I should see the icons and messages exactly like the prototype
