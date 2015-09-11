//
//  DetailsViewController.m
//  newsFeed
//
//  Created by Thibault Devillers on 04/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "DetailsViewController.h"
#import "WebViewController.h"
#import "PhotoViewController.h"
#import "MultimediaItem.h"
#import "UtilityClass.h"

// Queue for asynchronous photos loading
#define kBgPhotosQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// Specific TableView constants
static const float PHOTO_SIZE = 128;

@interface DetailsViewController ()
{
    UtilityClass *utilityClass;
    MultimediaItem *multimediaSmall;
    MultimediaItem *multimediaBig;
    BOOL fromFeedView;
}

@end

@implementation DetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fromFeedView = YES;
    utilityClass = [[UtilityClass alloc] init];

    // Set news section title
    self.newsSection.text = self.newsItem.section;

    // Set news title with TextView's height adapted to text
    NSString *newsTitle = self.newsItem.title;
    self.newsTitle.selectable = NO;
    [self.newsTitle.layoutManager ensureLayoutForTextContainer:self.newsTitle.textContainer];
    [self.newsTitle layoutIfNeeded];
    if (newsTitle.length == 0)
    {
        self.newsTitle.hidden = YES;
        self.newsTitleHeight.constant = 0;
    }
    else
    { [utilityClass changeTextView:self.newsTitle withText:newsTitle withHeight:self.newsTitleHeight]; }

    // Set news byline with TextView's height adapted to text
    NSString *newsByline = self.newsItem.byline;
    self.newsByline.selectable = NO;
    [self.newsByline.layoutManager ensureLayoutForTextContainer:self.newsByline.textContainer];
    [self.newsByline layoutIfNeeded];
    if (newsByline.length == 0)
    {
        self.newsByline.hidden = YES;
        self.newsBylineHeight.constant = 0;
    }
    else
    { [utilityClass changeTextView:self.newsByline withText:newsByline
                        withHeight:self.newsBylineHeight]; }
    
    // Get bigger news photo URLs from multimedia data
    multimediaSmall = nil;
    multimediaBig = nil;
    for (MultimediaItem *photoItem in self.newsItem.multimedia)
    {
        if ([photoItem.format isEqualToString:@"mediumThreeByTwo440"])
        { multimediaBig = photoItem; }
        else if ([photoItem.format isEqualToString:@"mediumThreeByTwo210"])
        { multimediaSmall = photoItem; }
    }
    
    // If the news item has the bigger news photo URLs, asynchroniously load, resize and display the image
    if ( (multimediaSmall == nil) || (multimediaBig == nil) )
    {
        self.newsPhotosView.hidden = YES;
        self.newsPhotosHeight.constant = 2;
    }
    else
    {
        UIImage *OriginalPhotoImage = [UIImage imageNamed:@"noImage.png"];
        UIImage* photoImage = [utilityClass imageWithImage:OriginalPhotoImage scaledToHeight:PHOTO_SIZE];
        
        CGRect frame = CGRectMake(0, 0, PHOTO_SIZE, PHOTO_SIZE);
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:frame];
        photoView.contentMode = UIViewContentModeCenter;
        photoView.clipsToBounds = YES;
        photoView.layer.borderColor = [[UIColor blackColor] CGColor];
        photoView.layer.borderWidth = 1.0;
        
        photoView.image = photoImage;
        
        [self.newsPhotosContainer addSubview:photoView];
        
        dispatch_async(kBgPhotosQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:multimediaSmall.url]];
            if (imgData)
            {
                UIImage *OriginalPhotoImage = [UIImage imageWithData:imgData];
                if (OriginalPhotoImage)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage* photoImage;
                        if (OriginalPhotoImage.size.width > OriginalPhotoImage.size.height)
                        { photoImage = [utilityClass imageWithImage:OriginalPhotoImage
                                             scaledToHeight:PHOTO_SIZE]; }
                        else
                        { photoImage = [utilityClass imageWithImage:OriginalPhotoImage
                                              scaledToWidth:PHOTO_SIZE]; }
                        
                        photoView.image = photoImage;
                        
                        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoViewSingleTap:)];
                        singleFingerTap.cancelsTouchesInView = NO;
                        [photoView addGestureRecognizer:singleFingerTap];
                        photoView.userInteractionEnabled = YES;
                    });
                }
            }
        });
    }
    
    // Set news abstract with TextView's height adapted to text
    NSString *newsAbstract = self.newsItem.abstract;
    self.newsAbstract.selectable = NO;
    [self.newsAbstract.layoutManager ensureLayoutForTextContainer:self.newsAbstract.textContainer];
    [self.newsAbstract layoutIfNeeded];
    if (newsAbstract.length == 0)
    {
        self.newsAbstract.hidden = YES;
        self.newsAbstractHeight.constant = 0;
    }
    else
    { [utilityClass changeTextView:self.newsAbstract withText:newsAbstract withHeight:self.newsAbstractHeight]; }
}

-(void)viewDidAppear:(BOOL)animated
{
    // If coming from the news feed page, resize news title & abstract TextViews if necessary
    if (fromFeedView)
    {
        NSString *newsTitle = self.newsItem.title;
        [utilityClass changeTextView:self.newsTitle withText:newsTitle withHeight:self.newsTitleHeight];
        
        NSString *newsAbstract = self.newsItem.abstract;
        [utilityClass changeTextView:self.newsAbstract withText:newsAbstract withHeight:self.newsAbstractHeight];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)changeTextView:(UITextView *)textView withText:(NSString *)text withHeight:(NSLayoutConstraint *) textHeight
{
    
    // Set text
    textView.text = text;
    
    // Adapt textView frame to the text
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, FLT_MAX)]; //CGFLOAT_MAX
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    // Change text container's height
    textHeight.constant = textView.frame.size.height;
}

// Resize image keeping scale with specific width
-(UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)newWidth
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = newWidth / oldWidth;
    float newHeight = sourceImage.size.height * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// Resize image keeping scale with specific height
-(UIImage*)imageWithImage:(UIImage*)sourceImage scaledToHeight:(float)newHeight
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = newHeight / oldHeight;
    float newWidth = sourceImage.size.width * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
*/
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowWebView"])
    {
        WebViewController *destViewController = segue.destinationViewController;
        destViewController.newsItem = self.newsItem;
        
        [self.navigationController pushViewController:destViewController animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"ShowPhotoView"])
    {
        PhotoViewController *destViewController = segue.destinationViewController;
        destViewController.photoItem = multimediaBig;
        
        [self.navigationController pushViewController:destViewController animated:YES];
    }
}

- (IBAction)unwindToDetailsView:(UIStoryboardSegue *)segue
{
    NSLog(@"unwindToDetailsView");
    fromFeedView = NO;
}

- (IBAction)clickButton:(id)sender
{
    [self performSegueWithIdentifier:@"ShowWebView" sender:self];
}

- (void)handlePhotoViewSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"ShowPhotoView" sender:self];
}

@end
