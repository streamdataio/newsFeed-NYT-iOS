//
//  WebViewController.h
//  newsFeed
//
//  Created by Thibault Devillers on 07/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"

@interface WebViewController : UIViewController

@property (weak, nonatomic) NewsItem *newsItem;

@property (weak, nonatomic) IBOutlet UIWebView *WebView;

@end
