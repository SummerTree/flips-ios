Feature: User Information screen
  As a user
  I want to view my profile informations
  So, I can update my informations

Scenario: Access user's information
  Given I am on the "Settings" screen
  When I touch "User's Information" option
  Then I should see "User information" fields filled

Scenario: Touching Back on user's information
  Given I am on the "User Information" screen
  When I touch "Back" button
  Then I should see "Settings" screen

Scenario Outline: Showing Save button
  Given I am on the "User Information" screen
  When I update the <field>
  Then I should see "Save" button
  | field |
  | Email |
  | photo |

Scenario Outline: Updating valid fields
  Given I am on the "User Information" screen
  When I update the <field>
  And I touch "Save" button
  Then I should see the new values on my profile
  | field |
  | Email |
  | photo |

Scenario: Turn back without saving changes
  Given I am on the "User Information" screen
  When I update the photo and email fields
  And I touch "Back" button
  Then I should see "Settings" screen
  And The changes shouldn't be saved

Scenario Outline: Updating invalid fields
  Given I am on the "User Information" screen
  When I update <field>
  Then I shouldn't be able to change this field
  | field      |
  | First Name |
  | Last Name  |
  | Password   |
  | Birthday   |

Scenario Outline: Changes to a invalid email
  Given I am on the "User Information" screen
  When I change the value of "Email" to "<email>"
  And I touch "Save" button
  Then I should see the message: "Your email should look like this mug@mail.com"
  | email             |
  | mugchat.com       |
  | mugchat@gmail     |

Scenario: Verifying design screen
  Given I am on the "User Information" screen
  Then The desing screen should be the same on the prototype design
