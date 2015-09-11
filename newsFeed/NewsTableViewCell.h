//
//  NewsTableViewCell.h
//  newsFeed
//
//  Created by Thibault Devillers on 07/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *newsSection;
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsBySectionTitle;

@end
