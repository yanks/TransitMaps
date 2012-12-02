//
//  TMDirectionTableViewCell.m
//  TransitMaps
//
//  Created by Jeff Forbes on 12/1/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import "TMDirectionTableViewCell.h"
#import "TMTripSegment.h"
#import "TMAnnotationImageHelper.h"

@implementation TMDirectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTripSegment:(TMTripSegment*)segment
{
	[_titleLabel setText:[segment segmentTitle]];
	[_subtitleLabel setText:[segment instructions]];
	[[self imageView] setImage:[TMAnnotationImageHelper imageForIconURL:[segment segmentIconURL]]];
	if( [segment transitDestination] ){
		[_stopLabel setText:[NSString stringWithFormat:@"Get off at %@", [segment transitDestination]]];
	}
	else [_stopLabel setText:@""];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
