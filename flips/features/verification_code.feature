Feature: Verification Code
  As a user
  I want to be security to change my password
  So I the send me a code to change my password

@7172 @7173
Scenario: Access Verification code screen by Forgot Password screen
  Given I am on the "<screen>" screen
  When I type 10 numbers
  Then I should see "Verification Code" screen
  | screen          |
  | Forgot Password |
  | Phone Number    |
  | Type Number     |

@7172 @7173
Scenario: Typed 3 times the wrong code
  Given I am on the "<screen>" screen
  And I go to "Verification Code" screen
  When I type the wrong code 3 times
  Then I should see a message: 3 incorrect entries. Check your messages for a new code.
  And I should see "OK" button
  And I should receive a new code
  | screen          |
  | Forgot Password |
  | Phone Number    |
  | Type Number     |

@7172 @7173
Scenario: I received a new code and I put an old code
  Given I am on the "<screen>" screen
  And I go to "Verification Code" screen
  And I touch 3 times the wrong code
  And I receive a new code
  When I type correctly the old code
  Then I should see a blue background on the code
  And I should see "!" icon
  | screen          |
  | Forgot Password |
  | Phone Number    |
  | Type Number     |

#I couldn't test because is crashing
@7172 @7173
Scenario: Touching Resend Code without code typed
  Given I am on the "Verification Code" screen
  When Don't type the code
  And I touch "Resend Code" button
  Then I should receive another verification code

@7172 @7173
Scenario: Entring with a wrong verification code
  Given I am on the "Verification Code" screen
  When I type a wrong code
  Then I should see a blue background on the code
  And I should see "!" icon

#I couldn't test because is crashing
@7172 @7173
Scenario: Resend Code when my code is wrong
  Given I am on the "Verification Code" screen
  And I type a wrong code
  When I touch "Resend Code" button
  Then I should receive another verification code

@7172 @7173
Scenario: Update the wrong code to a right one
  Given I am on the "<screen1>" screen
  And I go to "Verification Code" screen
  And A wrong code is typed
  When I correct the code
  Then The background turns red
  And I shouldn't see "!" icon
  And I should see "<screen2>" screen
  | screen1         | screen2      |
  | Forgot Password | New Password |
  | Phone Number    | Inbox        |
  | Type Number     | Settings     |

#I couldn't test because is crashing
@7172 @7173
Scenario: Touching Resend Code button when the code is right on Forgot Password screen
  Given I am on the "<screen1>" screen
  And I go to "Verification Code" screen
  When I type a right code
  Then I should see "<screen2>" screen
  | screen1         | screen2      |
  | Forgot Password | New Password |
  | Phone Number    | Inbox        |
  | Type Number     | Settings     |

@7172 @7173
Scenario: Changing phone number
  Given I am on the "Verification Code" screen
  And I touch "Back" button
  And I change the phone number
  When I go to "Verification Code"
  Then I should receive a new code on the new phone number

@7172 @7173
Scenario: Verifying title screen
  Given I am on the "Verification Code" screen
  Then I should see "Verification Code" as a title

@7172 @7173
Scenario: Verifying design screen
  Given I am on the "Verification Code" screen
  Then The desing screen should be the same on the prototype design
