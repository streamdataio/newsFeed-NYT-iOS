//
//  DetailsViewController.h
//  newsFeed
//
//  Created by Thibault Devillers on 04/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"

@interface DetailsViewController : UIViewController

@property (weak, nonatomic) NewsItem *newsItem;

@property (weak, nonatomic) IBOutlet UILabel *newsSection;

@property (weak, nonatomic) IBOutlet UITextView *newsTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsTitleHeight;

@property (weak, nonatomic) IBOutlet UITextView *newsByline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsBylineHeight;

@property (weak, nonatomic) IBOutlet UIView *newsPhotosView;
@property (weak, nonatomic) IBOutlet UIView *newsPhotosContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsPhotosHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsPhotosWidth;

@property (weak, nonatomic) IBOutlet UITextView *newsAbstract;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsAbstractHeight;

@end
