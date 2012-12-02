//
//  TMDirectionTableViewCell.h
//  TransitMaps
//
//  Created by Jeff Forbes on 12/1/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMTripSegment;

@interface TMDirectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;

- (void)setTripSegment:(TMTripSegment*)segment;

@end
