Feature: Login screen
  As a user
  I want to enter on Flips
  So, I can do login

@7224 @7171 @Flips-145
Scenario Outline: Accessing Login screen from device: 4s, 5 and 5s
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

@7224 @7171 @Flips-145
Scenario Outline: Accessing Login screen from device: 6 and 6Plus
  Given I am on the "Login" screen
  When I touch the field: "<field>"
  Then I should see the keyboard
  And The Flips icon should remain on the same way
  And Flips text should remais on the same way
  And The fields should animate down
  And I should see "Forgot Password" button
  | field    |
  | Email    |
  | Password |

@7224 @7171 @Flips-145
Scenario: Dismissing keyboard on devices: 4s, 5 and 5s
  Given I am on the "Login" screen
  And The cursor are in some field
  When I touch somewhere on "Login" screen
  Then The keyboard should dismiss
  And I should see Flips icon
  And Flips text and fields should animate down
  And I shouldn't see "Forgot Password" button

@7224 @7171 @Flips-145
Scenario: Dismissing keyboard on devices: 6 and 6Plus
  Given I am on the "Login" screen
  And The cursor are in some field
  When I touch somewhere on "Login" screen
  Then The keyboard should dismiss
  And I should keep seeing Flips icon and text
  And Email and Password fields should animate up
  And I shouldn't see "Forgot Password" button

@7224 @7171 @Flips-145
Scenario: Dismissing keyboard when the fields are filled
  Given I am on the "Login" screen
  And The fields are filled
  When I touch somewhere on "Login" screen
  Then The values on the fields should remain

@7171 @Flips-145
Scenario: Seeing Return button
  Given I am on the "Login" screen
  When I touch Email field
  Then I should see "Return" button on the keyboard

@7171 @Flips-145
Scenario: Touching Return button
  Given I am on the "Login" screen
  And The cursor is in Email field
  When I touch "Return" button on the keyboard
  Then I should see the cursor on the "Password" field

@7171 @Flips-145
Scenario: Seeing Done button
  Given I am on the "Login" screen
  When I touch Password field
  And I should see "Done" button

@7171 @Flips-145
Scenario: Touching Done with no value on the Email field
  Given I am on the "Login" screen
  And The <field1> field is not filled
  And The <field2> field is filled
  When I touch "Done" button
  Then I should see a message: "Please complete both fields."
  | field1   | field2   |
  | Email    | Password |
  | Password | Email    |

@7171 @Flips-145
Scenario: I already logged in on the app in this device
  Given I am on the "Login" screen
  When I already logged in with a valid account
  Then I should see this email on the "Email" field
  And I should see "Password" field clear

@Flips-145
Scenario: Changing Email and seeing it on Login screen
  Given I logged in and I change my email on Settings
  When I logout
  Then I should see my new email on the Login screen
  And I should see "Password" field clear

@7171 @Flips-145
Scenario: Login with right email and wrong password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "flip@mail.com"
  And I fill "Password" with the value: "Password2"
  And I touch "Done" button
  Then I should keep seeing "Forgot Password" button
  And I should see the icon "!" in both fields
  And I should see a message: "Username or Password incorrect, or account does not exist." button "Ok"

@7171 @Flips-145
Scenario: Login with wrong email and right password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mag@mail.com"
  And I fill "Password" with the value: "Password1"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!" in both fields
  And I should see a message: "Username or Password incorrect, or account does not exist." button "Ok"

@Flips-145
Scenario: Typing an Email bigger than Email field
  Given I am on the "Login" screen
  When I type an Email bigger than "Email" field
  Then The values should swipe while I type

@7171 @Flips-145
Scenario: Showing Email keyboard
  Given I am on the "Login" screen
  When I touch "Email" field
  Then I should see "Email" keyboard

@7171 @Flips-145
Scenario: Showing Alpha keyboard
  Given I am on the "Login" screen
  When I touch "Password" field
  Then I should see "Alpha" keyboard

@7171 @Flips-145 @Flips-28
Scenario: Verifying design screen
  Given I am on the "Login" screen
  Then The desing screen should be the same on the prototype design
