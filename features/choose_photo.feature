Feature: Choose Photo
  As an user
  I want to see the photos on my device divided in subfolders
  So I can select one photo easiest

Scenario Outline: Choosing a picture when you have more than one folder photos
  Given I am on the "<screen>" screen
  And I have more than one folder with pictures on my galery
  When I touch "Photo" icon
  Then I should see "<screen2>" screen
  And All folders of pictures existents on my galery
  | screen        | screen2      |
  | Take Picture  | Choose Photo |
  | Join Recorder | Albums       |

#Ben, in this scenario, Should I see Choose Photo screen ou Camera roll screen?
Scenario Outline: Choosing a picture when you have only one photo
  Given I am on the "<screen>" screen
  And I have only one photo on my galery
  When I touch "Photo" icon
  Then I should see "<screen2>" screen
  And I should see the photo
  | screen        | screen2      |
  | Take Picture  | Choose Photo |
  | Join Recorder | Albums       |

#Ben in this scenario, Should I see Photo icon?
Scenario Outline: Choosing a picture when you don't have pictures on the galery
  Given I am on the "<screen>" screen
  When I touch "Photo" icon
  And I don't have photos on my galery
  Then I should see "<screen2>" screen
  And I should see a message: "No Photos or Videos You can take photos and videos using the camera, or sync photos and videos onto your iPad usung iTunes."
  | screen        | screen2      |
  | Take Picture  | Choose Photo |
  | Join Recorder | Albums       |

Scenario: Touching X button
  Given I am on the "Choose Photo" screen
  When I touch "X" button
  Then I should see "Take Picture"

Scenario: Touching Back button
  Given I am on the "Albums" screen
  When I touch "Back" button
  Then I should see "Join Recorder" screen

Scenario Outline: Verifying title screen
  Given I am on the "<screen>" screen
  Then I should see "<title>" as a title
  | screen       | title        |
  | Choose Photo | Choose Photo |
  | Albums       | Albums       |

Scenario Outline: Verifying design screen
  Given I am on the "<screen>" screen
  Then The desing screen should be the same on the prototype design
  | screen       |
  | Choose Photo |
  | Albums       |
