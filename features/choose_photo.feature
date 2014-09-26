Feature: Choose Photo
  As a user
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
  | screen          | screen2      |
  | Take Picture    | Choose Photo |
  | Join Recorder   | Albums       |
  | Join Word Photo | Albums       |
  | Recorder        | Albums       |

Scenario Outline: Choosing a picture when you don't have pictures on the galery
  Given I am on the "<screen>" screen
  When I don't have photos on my galery
  Then I should see "Photo" icon
  | screen          |
  | Take Picture    |
  | Join Word Photo |
  | Join Recorder   |
  | Recorder        |

Scenario: Touching Photo icon when I don't have pictures on the galery
  Given I am seeing "Photo" icon
  And I don't have pictures on my galery
  When I touch "Photo" icon
  Then I should see a message informing me that I don't have pictures to choose

Scenario: Touching X button
  Given I am on the "Choose Photo" screen
  When I touch "X" button
  Then I should see "Take Picture"

Scenario Outline: Touching Back button
  Given I am on the "<screen>" screen
  And I go to "Albums" screen
  When I touch "Back" button
  Then I should see "<screen1>" screen
  | screen          | screen1         |
  | Join Word Photo | View Mug        |
  | Join Recorder   | View Mug        |
  | Recorder        | Join Word Photo |

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
