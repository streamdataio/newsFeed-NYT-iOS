//
//  MultimediaItem.h
//  newsFeed
//
//  Created by Thibault Devillers on 19/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultimediaItem : NSObject

@property (readonly) NSString *url;
@property (readonly) NSString *format;
@property (readonly) NSNumber *height;
@property (readonly) NSNumber *width;
@property (readonly) NSString *type;
@property (readonly) NSString *subtype;
@property (readonly) NSString *caption;
@property (readonly) NSString *copyright;

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@end
