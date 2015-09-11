//
//  PhotoViewController.h
//  newsFeed
//
//  Created by Thibault Devillers on 19/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultimediaItem.h"

@interface PhotoViewController : UIViewController

@property (weak, nonatomic) MultimediaItem *photoItem;

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewEqualWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewEqualHeight;

@end
