Feature: Register a user
  As a user
  I want to register access Flips
  So I have to register a user

@7170
Scenario: Access Register screen
  Given I am on the "Login" screen
  When I touch "Sign Up" button
  Then I should see "Sign Up" screen
  And The screen should animate right to left

@7170
Scenario Outline: Fill only one field
  Given I am on the "Sign Up" screen
  When I fill the field "<field>" with "<value>"
  Then The button "Next" should be disable
  | field      | value             |
  | First Name | First             |
  | Last Name  | Last              |
  | Email      | flip@gmail.com    |
  | Password   | Passwor8          |
  | Birthday   | 12/01/1987        |

@7170
Scenario: Adding a user already added
   Given I am on the "Sign Up" screen
   When I fill all fields with a user already added on data base
   And I touch "Done" button
   Then I should see a message: "An account already exists with that address. Try signing in, or sign up with a different email address."
   And The design should be the same the other messages like password and birthday wrong

@7170
Scenario Outline: Fill all fields with valid values and select a photo
  Given I am on the "Sign Up" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "flip@gmail.com"
  And I fill the field "Password" with "Passwor8"
  And I fill the field "Birthday" with "<birthday>"
  And I choose a photo
  And I touch "Next" button
  Then I should see "Phone Number" screen
  | birthday      |
  | today-13years |

@7170
Scenario: Fill all fields and don't select a photo
  Given I am on the "Sign Up" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "flip@gmail.com"
  And I fill the field "Password" with "Passwor8"
  And I fill the field "Birthday" with "<birthday>"
  And I don't choose a photo
  And I touch "Next" button
  Then I should see a message: "Hey, faceless wonder! Looks like your Flips is missing!"

@7170
Scenario Outline: Fill with invalid values
  Given I am on the "Sign Up" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "<email>"
  And I fill the field "Password" with "<password>"
  And I fill the field "Birthday" with "<birthday>"
  And I exit the field
  Then I should see the message: "<message>"
  And The "Next" button should keep disable
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

@7170
Scenario: Fixing wrong values
  Given I am on the "Sign Up" screen
  And I typed a wrong value on "<field>"
  When I fix this value
  And I exit the field
  Then The error message should dismiss
  | field    |
  | Email    |
  | Password |
  | Birthday |

@7170
Scenario: Swiping up warning messages panel
  Given I am on the "Sign Up" screen
  And I filled invalid values on the fields
  When I swipe up the warning messages panel
  Then I shouldn't see the panel

@7170
Scenario: Showing Alpha keyboard
  Given I am on the "Sign Up" screen
  When I touch "<field>" field
  Then I should see "Alpha" keyboard
  | field      |
  | First Name |
  | Last Name  |
  | Password   |

@7170
Scenario: Showing Email keyboard
  Given I am on the "Sign Up" screen
  When I touch "Email" field
  Then I should see "Email" keyboard

@7170
Scenario: Showing numeric keyboard
  Given I am on the "Sign Up" screen
  When I touch "Birthday" field
  Then I should see "Numeric" keyboard

@7170
Scenario: Birthday value when there is no value
  Given I am on the "Sign Up" screen
  When There is no value on the "Birthday" field
  And The cursor is not in the "Birthday" field
  Then I should see the text: "Birthday"

@7170
Scenario: Touching Birthday field
  Given I am on the "Sign Up" screen
  When I touch "Birthday" field
  Then I should see: "MM/DD/YYYY" instead of "Birthday"

@7170
Scenario: Filling 2 numbers(MM) on Birthday field
  Given I am on the "Sign Up" screen
  When The user types 2 characters on MM on "Birthday" field
  Then The cursor should automatically goes to MM

@7170
Scenario: Filling 2 numbers(DD) on Birthday field
  Given I am on the "Sign Up" screen
  When The user taps 2 characters on DD on "Birthday" field
  Then The cursor should automatically goes to YYYY

@7170
Scenario: Changing Birthday value
  Given I am on the "Sign Up" screen
  And I typed 2 characters
  When I change this values
  Then After I typed two values again the cursor should goes to the next character(DD or YYYY)

@7170
Scenario: Touching back button
  Given I am on the "Sign Up" screen
  When I touch "Back" button
  Then I should see "Login" screen

@7170
Scenario: Tapping Back and Sign up again
  Given I am on the "Sign Up" screen
  And All fields are filled
  When I touch "Back" button
  And I touch "Sign Up" again
  Then I should see all fields filled

@7170
Scenario: Changing the taken photo
  Given I am on the "Sign Up" screen
  And There is a photo already selected
  When I touch the picture
  Then I should change the picture

@7170
Scenario: Verifying design
  Given I am on the "Sign Up" screen
  Then I should see the icons exactly like the prototype
