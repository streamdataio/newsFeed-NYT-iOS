//
//  NewsItem.m
//  newsFeed
//
//  Created by Thibault Devillers on 07/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "NewsItem.h"
#import "MultimediaItem.h"
#import "UtilityClass.h"

@implementation NewsItem

// Init the object with information from a dictionary
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary
{
    UtilityClass *utilityClass = [[UtilityClass alloc] init];
    
    if (self = [self init])
    {
        //NSString *boolean;
        // Assign all properties with keyed values from the dictionary
        _section = [jsonDictionary objectForKey:@"section"];
        _subsection = [jsonDictionary objectForKey:@"subsection"];
        _title = [utilityClass stringByDecodingHTMLEntitiesInString:[jsonDictionary
                                                                     objectForKey:@"title"]];
        _abstract = [utilityClass stringByDecodingHTMLEntitiesInString:[jsonDictionary
                                                                        objectForKey:@"abstract"]];
        _url = [jsonDictionary objectForKey:@"url"];
        _byline = [utilityClass stringByDecodingHTMLEntitiesInString:[jsonDictionary
                                                                      objectForKey:@"byline"]];
        _thumbnail_standard = [jsonDictionary objectForKey:@"thumbnail_standard"];

        _item_type = [jsonDictionary objectForKey:@"item_type"];
        _source = [jsonDictionary objectForKey:@"source"];
        _kicker = [jsonDictionary objectForKey:@"kicker"];
        _subheadline = [jsonDictionary objectForKey:@"subheadline"];
        _blog_name = [jsonDictionary objectForKey:@"blog_name"];
        
        _material_type_facet = [jsonDictionary objectForKey:@"material_type_facet"];

        const id desObject = [jsonDictionary objectForKey:@"des_facet"];
        if ([desObject respondsToSelector:@selector(count)])
        { _des_facet = [jsonDictionary objectForKey:@"des_facet"]; }
        else
        { _des_facet = nil; }

        const id orgObject = [jsonDictionary objectForKey:@"org_facet"];
        if ([orgObject respondsToSelector:@selector(count)])
        { _org_facet = [jsonDictionary objectForKey:@"org_facet"]; }
        else
        { _org_facet = nil; }
        
        const id perObject = [jsonDictionary objectForKey:@"per_facet"];
        if ([perObject respondsToSelector:@selector(count)])
        { _per_facet = [jsonDictionary objectForKey:@"per_facet"]; }
        else
        { _per_facet = nil; }
        
        const id geoObject = [jsonDictionary objectForKey:@"geo_facet"];
        if ([geoObject respondsToSelector:@selector(count)])
        { _geo_facet = [jsonDictionary objectForKey:@"geo_facet"]; }
        else
        { _geo_facet = nil; }
        
        const id multimediaObject = [jsonDictionary objectForKey:@"multimedia"];
        if ([multimediaObject respondsToSelector:@selector(count)])
        {
            //_multimedia = [jsonDictionary objectForKey:@"multimedia"];
            NSMutableArray *multimediaArray = [[NSMutableArray alloc] init];
            for (NSDictionary *multimediaDictionnary in multimediaObject)
            {
                MultimediaItem *multimediaItem = [[MultimediaItem alloc] initWithJSONDictionary:multimediaDictionnary];
                [multimediaArray addObject:multimediaItem];
            }
            _multimedia = multimediaArray;
        }
        else
        { _multimedia = nil; }

        _related_urls = [jsonDictionary objectForKey:@"related_urls"];
        
        _created_date = [jsonDictionary objectForKey:@"created_date"];
        _updated_date = [jsonDictionary objectForKey:@"updated_date"];
        _published_date = [jsonDictionary objectForKey:@"published_date"];
    }
    
    return self;
}

@end
