Feature: Login screen
  As an user
  I want to enter on MugChat
  So, I can do login

@7224 @7171
Scenario Outline: Missing keyboard
  Given I am on the "Login" screen
  When I touch the field: "<field>"
  Then I should see the keyboard
  And The MugChat icon should animate off the top
  And MugChat text should animates further up
  And The fields should animate up
  | field    |
  | Email    |
  | Password |

@7224 @7171
Scenario: Dismissing keyboard when the fields are empty
  Given I am on the "Login" screen
  And The cursor are on some field
  When I touch somewhere on "Login" screen
  Then The keyboard should dismiss
  And I should see MugChat icon
  And MugChat text and fields should animate down

@7224 @7171
Scenario: Dismissing keyboard when the fields are filled
  Given I am on the "Login" screen
  And The fields are filled
  When I touch somewhere on "Login" screen
  Then The keyboard should dismiss
  And I should see MugChat icon
  And MugChat text and fields should animate down

Scenario Outline: Return button
  Given I am on the "Login" screen
  When I fill "<field1>" field
  And Don’t fill "<field2>" field
  Then I should see "Return" button on the keyboard
  And I shouldn't see "Done" button
  | field1   | field2   |
  | Email    | Password |
  | Password | Email    |

Scenario: Done button
  Given I am on the "Login" screen
  When I fill "Email" field
  And I fill "Password" field
  Then I should see "Done" button on the keyboard

Scenario Outline: Invalid values
  Given I am on the "Login" screen
  When I fill "<field>" field with the value "<value>"
  And I exit the field
  Then I should see the message: "<message>"
  And The "Done" button should keep disable
  | field    | value    | message                                                     |
  | Email    | mug@mail | You email should look like this mug@mail.com                |
  | Email    | mug.com  | You email should look like this mug@mail.com                |
  | Password | Mugcha1  | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | Password | 12345678 | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | Password | Mugcchat | Your password should be 8+ Characters, Mixed Case, 1 Number |
  | Password | mugchat1 | Your password should be 8+ Characters, Mixed Case, 1 Number |

Scenario: Fixing wrong values
  Given I am on the "Login" screen
  And I typed a wrong value on "<field>"
  And I am seeing a warning message
  When I fix this value
  Then I shouldn't see the message
  | field    |
  | Email    |
  | Password |

Scenario: Swiping up warning messages panel
  Given I am on the "Login" screen
  And I filled invalid values on the fields
  When I swipe up the warning messages panel
  Then I shouldn't see the panel

Scenario: Swiping down warning messages panel
  Given I am on the "Login" screen
  And I filled invalid values on the fields
  And The warning messages panel is swiped up
  When I swipe down the warning messages panel
  Then I should see the panel again

Scenario: I already logged in on the app in this device
  Given I am on the "Login" screen
  When I already logged in with a valid account
  Then I should see this email on the "Email" field

Scenario: Login with right email and wrong password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mug@mail.com"
  And I fill "Password" with the value: "Mugchat2"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!" between the fields

Scenario: Login with wrong email and right password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mag@mail.com"
  And I fill "Password" with the value: "Mugchat1"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!" between the fields

Scenario: Verifying design screen
  Given I am on the "Login" screen
  Then The desing screen should be the same on the prototype design
