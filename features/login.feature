Feature: Login screen
  As a user
  I want to enter on Flips
  So, I can do login

# For iPhone 6 / 6+ the animation is different
@7224 @7171
Scenario Outline: Showing keyboard
  Given I am on the "Login" screen
  When I touch the field: "<field>"
  Then I should see the keyboard
  And The Flips icon should animate off the top
  And Flips text should animates further up
  And The fields should animate up
  And I should see "Forgot Password" button
  | field    |
  | Email    |
  | Password |

# For iPhone 6 / 6+ the animation is different
@7224 @7171
Scenario: Dismissing keyboard when the fields are empty
  Given I am on the "Login" screen
  And The cursor are on some field
  When I touch somewhere on "Login" screen
  Then The keyboard should dismiss
  And I should see Flips icon
  And Flips text and fields should animate down
  And I shouldn't see "Forgot Password" button

@7224 @7171
Scenario: Dismissing keyboard when the fields are filled
  Given I am on the "Login" screen
  And The fields are filled
  When I touch somewhere on "Login" screen
  Then The values on the fields should remain

@7171
Scenario: Seeing Return button
  Given I am on the "Login" screen
  When I touch Email field
  Then I should see "Return" button on the keyboard

@7171
Scenario: Touching Return button
  Given I am on the "Login" screen
  And The cursor is in Email field
  When I touch "Return" button on the keyboard
  Then I should see the cursor on the "Password" field

@7171
Scenario: Seeing Done button
  Given I am on the "Login" screen
  When I touch Password field
  And I should see "Done" button

@7171
Scenario: Touching Done with no value on the Email field
  Given I am on the "Login" screen
  And The Email field is not filled
  And The Password field is filled
  When I touch "Done" button
  Then I should see a message: "Please complete both fields."

@7171
Scenario Outline: Invalid values
  Given I am on the "Login" screen
  When I fill "<field>" field with the value "<value>"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see icon "!" in both fields
  Examples:
  | field    | value     |
  | Email    | flip@mail |
  | Email    | flip.com  |
  | Password | Passwo1   |
  | Password | 12345678  |
  | Password | Password  |
  | Password | passwor1  |

@7171
Scenario: I already logged in on the app in this device
  Given I am on the "Login" screen
  When I already logged in with a valid account
  Then I should see this email on the "Email" field

@7171
Scenario: Login with right email and wrong password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "flip@mail.com"
  And I fill "Password" with the value: "Password2"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!" in both fields

@7171
Scenario: Login with wrong email and right password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mag@mail.com"
  And I fill "Password" with the value: "Password1"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!" in both fields

@7171
Scenario: Showing Email keyboard
  Given I am on the "Login" screen
  When I touch "Email" field
  Then I should see "Email" keyboard

@7171
Scenario: Showing Alpha keyboard
  Given I am on the "Login" screen
  When I touch "Password" field
  Then I should see "Alpha" keyboard

@7171
Scenario: Verifying design screen
  Given I am on the "Login" screen
  Then The desing screen should be the same on the prototype design
