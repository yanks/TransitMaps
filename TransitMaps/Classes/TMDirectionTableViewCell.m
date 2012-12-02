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
		[_subtitleLabel setNumberOfLines:1];
		CGRect frame = [_subtitleLabel frame];
		frame.size.height = 18;
		[_subtitleLabel setFrame:frame];
		[_stopLabel setText:[NSString stringWithFormat:@"Get off at %@", [segment transitDestination]]];
		[_departsLabel setText:[segment segmentSubtitle]];
	}
	else{
		[_subtitleLabel setNumberOfLines:2];
		CGRect frame = [_subtitleLabel frame];
		frame.size.height = 36;
		[_subtitleLabel setFrame:frame];
		[_stopLabel setText:@""];
		[_departsLabel setText:@""];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
