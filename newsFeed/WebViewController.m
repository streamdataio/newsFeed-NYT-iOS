//
//  WebViewController.m
//  newsFeed
//
//  Created by Thibault Devillers on 07/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load the news webpage from the news URL in the WebView
    NSString *fullURL = self.newsItem.url;
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.WebView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
