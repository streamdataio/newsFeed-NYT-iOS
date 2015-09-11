//
//  PhotoViewController.m
//  newsFeed
//
//  Created by Thibault Devillers on 19/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the news photo from the news photo URL
    UIImage* OriginalPhotoImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:self.photoItem.url]]];
    self.photoImageView.image = OriginalPhotoImage;
    //NSLog(@"Original photo size = %f - %f", OriginalPhotoImage.size.width, OriginalPhotoImage.size.height);

    // Remove the unnecessary csize constraint depending on photo orientation
    if (OriginalPhotoImage.size.width > OriginalPhotoImage.size.height)
    { [self.photoView removeConstraint:self.photoViewEqualHeight]; }
    else
    { [self.photoView removeConstraint:self.photoViewEqualWidth]; }
 
    // Add an aspect ratio constraint to keep the scale of the photo
    float scaleFactor = OriginalPhotoImage.size.height / OriginalPhotoImage.size.width;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoImageView attribute:NSLayoutAttributeWidth multiplier:scaleFactor constant:0.0f];
    [self.photoImageView addConstraint:constraint];
}

-(void)viewDidAppear:(BOOL)animated
{
    // If the width of the resized photo is larger than the photo view (only know after view did appear due to autolayout), resize the photo to fit the width of the view
    if (self.photoImageView.frame.size.width > self.photoView.frame.size.width)
    {
        [self.photoView removeConstraint:self.photoViewEqualHeight];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
        [self.photoView addConstraint:constraint];
    }
    
    //NSLog(@"View size = %f - %f", self.photoView.frame.size.width, self.photoView.frame.size.height);
    //NSLog(@"Photo size = %f - %f", self.photoImageView.frame.size.width, self.photoImageView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
