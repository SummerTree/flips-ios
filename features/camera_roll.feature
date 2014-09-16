Feature: Camera Roll
  As an user
  I don't want to take a photo
  So I can select a photo on my device

Scenario: Access Camera Roll screen
  Given I am on the "Choose Photo" screen
  When I touch an iten
  Then I should see "Camera Roll" screen
  | screen       |
  | Choose Photo |
  | Albums       |

Scenario: Selectiong a picture
  Given I am on the "Camera Roll" screen
  When I touch a photo
  Then I should see "<screen>" screen
  And I should see the selected foto on the photo circle
  | screen        |
  | Register      |
  | Join Recorder |

Scenario: Touching Back button on Camera roll screen
  Given I am on the "Camera Roll" screen
  When I touch "Back" button
  Then I should see "<screen>" screen
  | screen       |
  | Choose Photo |
  | Albums       |

Scenario: Verifying title screen
  Given I am on the "Camera Roll" screen
  Then I should see "Camera Roll" as a title

Scenario: Verifying design screen
  Given I am on the "Camera Roll" screen
  Then The desing screen should be the same on the prototype design
