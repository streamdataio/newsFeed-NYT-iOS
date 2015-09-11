//
//  MultimediaItem.m
//  newsFeed
//
//  Created by Thibault Devillers on 19/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "MultimediaItem.h"
#import "UtilityClass.h"

@implementation MultimediaItem

// Init the object with information from a dictionary
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary
{
    UtilityClass *utilityClass = [[UtilityClass alloc] init];
    
    if(self = [self init])
    {
        // Assign all properties with keyed values from the dictionary
        _url = [jsonDictionary objectForKey:@"url"];
        _format = [jsonDictionary objectForKey:@"format"];
        _height = [jsonDictionary objectForKey:@"height"];
        _width = [jsonDictionary objectForKey:@"width"];
        _type = [jsonDictionary objectForKey:@"type"];
        _subtype = [jsonDictionary objectForKey:@"subtype"];
        
        const id captionObject = [jsonDictionary objectForKey:@"caption"];
        if ([captionObject isEqual:[NSNull null]])
        { _caption = @""; }
        else
        { _caption = [utilityClass stringByDecodingHTMLEntitiesInString:
                      [jsonDictionary objectForKey:@"caption"]]; }

        const id copyrightObject = [jsonDictionary objectForKey:@"caption"];
        if ([copyrightObject isEqual:[NSNull null]])
        { _copyright = @""; }
        else
        { _copyright = [utilityClass stringByDecodingHTMLEntitiesInString:
                        [jsonDictionary objectForKey:@"copyright"]]; }
    }
    
    return self;
}

@end
