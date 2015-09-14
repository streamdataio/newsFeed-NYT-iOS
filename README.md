# newsFeed-NYT-iOS
Server-Sent Events for iOS
Realtime news feed application for iOS using a New York Times API

This tutorial demonstrates how to implement Servent-Sent Event (aka SSE) for iOS using Streamdata.io
Please refer to the associated blogpost at http://streamdata.io/blog/server-sent-events-for-ios/

Follow these steps to make it work:

1- Create a free NYT developer account at http://developer.nytimes.com/ to get a NYT API Key.

2- Create a free account on Streamdata.io to get your Public and Private Keys at https://portal.streamdata.io/#/register.

3- Launch Xcode on your Mac and open the newsFeed project.

3- Edit FeedViewController.m and replace [YOUR_NYT_API_KEY] and [YOUR_STREAMDATA_APP_TOKEN] with the appropriate keys.

4- Save and run in the iOS Simulator or on your iPhone.

You are done! The app should build and run, and the initial news feed tableView displayed on your device. 

As soon as a news feed update is received, UI gets animated and the news feed TableView is modified.
The TableView can be ordered by latest news or by section.
You can visualize time since last update as well as the JSON data coming from Streamdata.io.
When selecting a specific cell, the details page for the selected news is displayed. From this page, you can open the news from the NYT website in a WebView.
