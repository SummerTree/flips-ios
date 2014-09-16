Feature: Login screen
  As an user
  I want to enter on MugChat
  So, I can do login

Scenario Outline: Access Login screen
  Given I am on the "Splash" screen
  When I touch the field: <field>
  Then I should see "Login" screen
  | field    |
  | Email    |
  | Password |

Scenario Outline: Missing the keyboard
  Given I am on the "Splash" screen
  When I touch the field: <field>
  Then I should see the keyboard
  | field    |
  | Email    |
  | Password |

Scenario: Showing the keyboard
  Given I am on the "Login" screen
  And The keyboard is open
  And There are value typed on the fields
  When I touch somewhere on "Login" screen
  Then The keyboard should dismiss
  And I should see "Splash" screen
  But the filds should keep with the values typed

Scenario Outline: Return button
  Given I am on the "Login" screen
  When I fill <field1>  field
  And Don’t fill <field2> field
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

Scenario Outline: Invalid email
  Given I am on the "Login" screen
  And the field "Password" is filled
  When I fill "Email" field with the value "<value>"
  And I touch "Done" button
  Then I should see the message: "You email should look like this mug@mail.com"
  | value    |
  | mug@mail |
  | mug.com  |

Scenario: Fixing wrong values
  Given I am on the "Login" screen
  And I typed a wrong value on "<field>"
  And I am seeing a warning message
  When I fix this value
  Then I shouldn't see the message
  | field    |
  | Email    |
  | Password |

Scenario Outline: Invalid password
  Given I am on the "Login" screen
  And the field "Email" is filled
  When I fill "Password" field with the value "<value>"
  And I touch "Done" button
  Then I should see the message: "Your password should be 8+ Characters, Mixed Case, 1 Number"
  | value    |
  | Mugcha1  |
  | 12345678 |
  | Mugcchat |
  | mugchat1 |

Scenario: Login with right email and wrong password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mug@mail.com"
  And I fill "Password" with the value: "Mugchat2"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!"

Scenario: Login with wrong email and right password
  Given I am on the "Login" screen
  When I fill "Email" with the value: "mag@mail.com"
  And I fill "Password" with the value: "Mugchat1"
  And I touch "Done" button
  Then I should see "Forgot Password" button
  And I should see the icon "!"

Scenario: Verifying design screen
  Given I am on the "Login" screen
  Then The desing screen should be the same on the prototype design
