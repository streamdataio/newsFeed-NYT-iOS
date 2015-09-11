//
//  NewsItem.h
//  newsFeed
//
//  Created by Thibault Devillers on 07/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsItem : NSObject

@property (readonly) NSString *section;
@property (readonly) NSString *subsection;
@property (readonly) NSString *title;
@property (readonly) NSString *abstract;
@property (readonly) NSString *url;
@property (readonly) NSString *byline;
@property (readonly) NSString *thumbnail_standard;

@property (readonly) NSString *item_type;
@property (readonly) NSString *source;
@property (readonly) NSString *kicker;
@property (readonly) NSString *subheadline;
@property (readonly) NSString *blog_name;

@property (readonly) NSString *material_type_facet;
@property (readonly) NSArray *des_facet;
@property (readonly) NSArray *org_facet;
@property (readonly) NSArray *per_facet;
@property (readonly) NSArray *geo_facet;

@property (readonly) NSArray *multimedia;
@property (readonly) NSArray *related_urls;

@property (readonly) NSString *created_date;
@property (readonly) NSString *updated_date;
@property (readonly) NSString *published_date;

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@end
