Feature: Register a user
  As a user
  I want to register access MugChat
  So I have to register a user

@7170
Scenario: Access Register screen
  Given I am on the "Login" screen
  When I touch "Sign Up" button
  Then I should see "Register" screen
  And The screen should animate right to left

@7170
Scenario Outline: Fill only one field
  Given I am on the "Register" screen
  When I fill the field "<field>" with "<value>"
  Then The button "Next" should be disable
  | field      | value             |
  | First Name | First             |
  | Last Name  | Last              |
  | Email      | mugchat@gmail.com |
  | Password   | MugChat8          |
  | Birthday   | 12/01/1987        |

@7170
Scenario Outline: Fill all fields with valid values and select a photo
  Given I am on the "Register" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "mugchat@gmail.com"
  And I fill the field "Password" with "MugChat8"
  And I fill the field "Birthday" with "<birthday>"
  And I choose a photo
  And I touch "Next" button
  Then I should see "Phone Number" screen
  | birthday      |
  | today-13years |

@7170
Scenario: Fill all fields and don't select a photo
  Given I am on the "Register" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "mugchat@gmail.com"
  And I fill the field "Password" with "MugChat8"
  And I fill the field "Birthday" with "<birthday>"
  And I don't choose a photo
  Then The button "Next" should be disable

@7170
Scenario Outline: Fill with invalid values
  Given I am on the "Register" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "<email>"
  And I fill the field "Password" with "<password>"
  And I fill the field "Birthday" with "<birthday>"
  And I exit the field
  Then I should see the message: "<message>"
  And The "Next" button should keep disable
  | email             | password | birthday         | message                                                     |
  | mugchat.com       | MugChat8 | 12/01/1987       | Your email should look like this mug@mail.com               |
  | mugchat@gmail     | MugChat8 | 12/01/1987       | Your email should look like this mug@mail.com               |
  | mugchat@gmail.com | mugchat8 | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | mugchat@gmail.com | mugChatt | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | mugchat@gmail.com | 12345678 | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | mugchat@gmail.com | mugCha8  | 12/01/1987       | You must be at least 13 years old                           |
  | mugchat@gmail.com | mugChat8 | today + 1d       | You must be at least 13 years old                           |
  | mugchat@gmail.com | mugchat8 | today-13years+1d | You must be at least 13 years old                           |
  | mugchat@gmail.com | mugchat8 | today            | You must be at least 13 years old                           |

@7170
Scenario: Fixing wrong values
  Given I am on the "Register" screen
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
  Given I am on the "Register" screen
  And I filled invalid values on the fields
  When I swipe up the warning messages panel
  Then I shouldn't see the panel

@7170
Scenario: Swiping down warning messages panel
  Given I am on the "Register" screen
  And I filled invalid values on the fields
  And The warning messages panel is swiped up
  When I swipe down the warning messages panel
  Then I should see the panel again

@7170
Scenario: Showing Alpha keyboard
  Given I am on the "Register" screen
  When I touch "<field>" field
  Then I should see "Alpha" keyboard
  | field      |
  | First Name |
  | Last Name  |
  | Password   |

@7170
Scenario: Showing Email keyboard
  Given I am on the "Register" screen
  When I touch "Email" field
  Then I should see "Email" keyboard

@7170
Scenario: Showing numeric keyboard
  Given I am on the "Register" screen
  When I touch "Birthday" field
  Then I should see "Numeric" keyboard

@7170
Scenario: Birthday value when there is no value
  Given I am on the "Register" screen
  When There is no value on the "Birthday" field
  And The cursor is not in the "Birthday" field
  Then I should see the text: "Birthday"

@7170
Scenario: Touching Birthday field
  Given I am on the "Register" screen
  When I touch "Birthday" field
  Then I should see: "DD/MM/YYYY" instead of "Birthday"

@7170
Scenario: Filling 2 numbers(MM) on Birthday field
  Given I am on the "Register" screen
  When The user types 2 characters on MM on "Birthday" field
  Then The cursor should automatically goes to DD

@7170
Scenario: Filling 2 numbers(DD) on Birthday field
  Given I am on the "Register" screen
  When The user taps 2 characters on DD on "Birthday" field
  Then The cursor should automatically goes to YYYY

@7170
Scenario: Changing Birthday value
  Given I am on the "Register" screen
  And I typed 2 characters
  When I change this values
  Then After I typed two values again the cursor should goes to the next character(DD or YYYY)

@7170
Scenario: Touching back button
  Given I am on the "Register" screen
  When I touch "Back" button
  Then I should see "Login" screen

@7170
Scenario: Tapping Back and Sign up again
  Given I am on the "Register" screen
  And All fields are filled
  When I touch "Back" button
  And I touch "Sign Up" again
  Then I should see all fields filled

@7170
Scenario: Changing the taken photo
  Given I am on the "Register" screen
  And There is a photo already selected
  When I touch the picture
  Then I should change the picture

@7170
Scenario: Verifying design
  Given I am on the "Register" screen
  Then I should see the icons exactly like the prototype
