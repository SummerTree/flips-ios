Feature: Choose Photo
  As an user
  I want to see the photos on my device divided in subfolders
  So I can select one photo easiest


Scenario: Choosing a picture when you have more than one folder photos
  Given I am on the "Take Picture" screen
  And I have more than one folder with pictures on my galery
  When I touch "Photo" icon
  Then I should see "Choose Photo" screen
  And All folders of pictures existents on my galery

Scenario: Choosing a picture when you have only one photo
  Given I am on the "Take Picture" screen
  And I have only one photo on my galery
  When I touch "Photo" icon
  Then I should see "Choose Photo" screen #Choose screen or Camera roll?
  And I should see the photo

Scenario: Choosing a picture when you don't have pictures on the galery
  Given I am on the "Take Picture" screen
  When I touch "Photo" icon
  And I don't have photos on my galery
  Then I should see "Choose Photo" screen
  And I should see a message: "No Photos or Videos You can take photos and videos using the camera, or sync photos and videos onto your iPad usung iTunes."

Scenario: Touching X button
  Given I am on the "Choose Photo" screen
  When I touch "X" button
  Then I should see "Take Picture"
