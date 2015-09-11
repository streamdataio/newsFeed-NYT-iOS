//
//  MethodCollection.h
//  newsFeed
//
//  Created by Thibault Devillers on 02/09/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UtilityClass : NSObject

// Decode HTML entities to NSString
- (NSString *)stringByDecodingHTMLEntitiesInString:(NSString *)input;

// Resize textView to adapt to text with fixed width
- (void)changeTextView:(UITextView *)textView withText:(NSString *)text withHeight:(NSLayoutConstraint *) textHeight;

// Resize image keeping scale with specific width
-(UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)newWidth;

// Resize image keeping scale with specific height
-(UIImage*)imageWithImage:(UIImage*)sourceImage scaledToHeight:(float)newHeight;

@end
