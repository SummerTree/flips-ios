Feature: Register a user
  As an user
  I want to register access MugChat
  So I have to register a user


Scenario: Touch Sign Up button
  Given I am on the "Login" screen
  When I touch "Sign Up" button
  Then I should see "Register" screen

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

Scenario Outline: Fill all fields and select a photo
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
  | today         |
  | today-13years |

Scenario: Fill all fields and don't select a photo
  Given I am on the "Register" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "mugchat@gmail.com"
  And I fill the field "Password" with "MugChat8"
  And I fill the field "Birthday" with "<birthday>"
  And I don't choose a photo
  Then The button "Next" should be disable

Scenario Outline: Fill with invalid values
  Given I am on the "Register" screen
  When I fill the field "First Name" with "First"
  And I fill the field "Last Name" with "Last"
  And I fill the field "Email" with "<email>"
  And I fill the field "Password" with "<password>"
  And I fill the field "Birthday" with "<birthday>"
  And I touch "Next" button
  Then I should see the message: "<message>"
  | email             | password | birthday         | message                                                     |
  | mugchat.com       | MugChat8 | 12/01/1987       | Your email should look like this mug@mail.com               |
  | mugchat@gmail     | MugChat8 | 12/01/1987       | Your email should look like this mug@mail.com               |
  | mugchat@gmail.com | mugchat8 | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | mugchat@gmail.com | mugChatt | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | mugchat@gmail.com | 12345678 | 12/01/1987       | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | mugchat@gmail.com | mugCha8  | 12/01/1987       | You must be at least 13 years old                           |
  | mugchat@gmail.com | mugChat8 | today + 1d       | You must be at least 13 years old                           |
  | mugchat@gmail.com | mugchat8 | today-13years+1d | You must be at least 13 years old                           |

Scenario: Touching back button
  Given I am on the "Register" screen
  When I touch "Back" button
  Then I should see "Login" screen

Scenario: Touching Photo icon when the fields are not filled
  Given I am on the "Register" screen
  And All fields are filled
  When I touch "Image" icon
  Then Nothing should happend

Scenario: Changing the taked photo
  Given I am on the "Register" screen
  And There is a photo already selected
  When I touch the picture
  Then Nothing should happend  

@manual
Scenario: Verifying design
  Given I am on the "Register" screen
  Then I should see the icons exactly like the prototype
