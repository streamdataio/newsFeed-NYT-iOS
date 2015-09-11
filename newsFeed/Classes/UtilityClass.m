//
//  MethodCollection.m
//  newsFeed
//
//  Created by Thibault Devillers on 02/09/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "UtilityClass.h"

@implementation UtilityClass

// Decode HTML entities to NSString
- (NSString *)stringByDecodingHTMLEntitiesInString:(NSString *)input
{
    NSMutableString *results = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:input];
    [scanner setCharactersToBeSkipped:nil];
    while (![scanner isAtEnd])
    {
        NSString *temp;
        if ([scanner scanUpToString:@"&" intoString:&temp])
        { [results appendString:temp]; }
        if ([scanner scanString:@"&" intoString:NULL])
        {
            BOOL valid = YES;
            unsigned c = 0;
            NSUInteger savedLocation = [scanner scanLocation];
            if ([scanner scanString:@"#" intoString:NULL])
            {
                // it's a numeric entity
                if ([scanner scanString:@"x" intoString:NULL])
                {
                    // hexadecimal
                    unsigned int value;
                    if ([scanner scanHexInt:&value])
                    { c = value; }
                    else
                    { valid = NO; }
                }
                else
                {
                    // decimal
                    int value;
                    if ([scanner scanInt:&value] && value >= 0)
                    { c = value; }
                    else
                    { valid = NO; }
                }
                if (![scanner scanString:@";" intoString:NULL])
                {
                    // not ;-terminated, bail out and emit the whole entity
                    valid = NO;
                }
            }
            else
            {
                if (![scanner scanUpToString:@";" intoString:&temp])
                {
                    // &; is not a valid entity
                    valid = NO;
                }
                else if (![scanner scanString:@";" intoString:NULL])
                {
                    // there was no trailing ;
                    valid = NO;
                }
                else if ([temp isEqualToString:@"amp"])     { c = '&'; }
                else if ([temp isEqualToString:@"quot"])    { c = '"'; }
                else if ([temp isEqualToString:@"lt"])      { c = '<'; }
                else if ([temp isEqualToString:@"gt"])      { c = '>'; }
                else
                {
                    // unknown entity
                    valid = NO;
                }
            }
            if (!valid)
            {
                // we errored, just emit the whole thing raw
                [results appendString:[input substringWithRange:NSMakeRange(savedLocation, [scanner scanLocation]-savedLocation)]];
            }
            else
            { [results appendFormat:@"%C", (unichar)c]; }
        }
    }
    
    return results;
}

// Resize textView to adapt to text with fixed width
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

@end
