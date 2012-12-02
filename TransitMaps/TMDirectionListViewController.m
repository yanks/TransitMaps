//
//  TMDirectionListViewController.m
//  TransitMaps
//
//  Created by Jeff Forbes on 12/1/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import "TMDirectionListViewController.h"
#import "TMTrip.h"
#import "TMTripSegment.h"
#import "TMAnnotationImageHelper.h"

@interface TMDirectionListViewController ()

@end

@implementation TMDirectionListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_trip segments] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* __reuseIdentifier = @"DirectionListReuseIdentifier";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:__reuseIdentifier];
	if( !cell ){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:__reuseIdentifier];
	}
	TMTripSegment* segment = [[_trip segments] objectAtIndex:indexPath.row];
	[[cell textLabel] setText:[segment segmentTitle]];
	[[cell detailTextLabel] setText:[segment instructions]];
	[[cell imageView] setImage:[TMAnnotationImageHelper imageForIconURL:[segment segmentIconURL]]];
	return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedDone:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
