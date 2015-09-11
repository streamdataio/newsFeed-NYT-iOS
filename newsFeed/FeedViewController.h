//
//  ViewController.h
//  newsFeed
//
//  Created by Thibault Devillers on 03/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRVSEventSourceDelegate.h"

// The view controller implements EventSourceDelegate
@interface FeedViewController : UIViewController <TRVSEventSourceDelegate, UITableViewDataSource, UIWebViewDelegate>

// TableView objects used to display the news feed
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (weak, nonatomic) IBOutlet UITableView *feedBySectionTableView;


// Switch button to switch between the 2 TableViews
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

// Time label to display the time lapse since last update
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

// WebView to display the JSON data coming from the Streamdata.io call
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeight;

@end
