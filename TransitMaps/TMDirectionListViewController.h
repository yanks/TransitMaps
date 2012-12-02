//
//  TMDirectionListViewController.h
//  TransitMaps
//
//  Created by Jeff Forbes on 12/1/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMTrip;

@interface TMDirectionListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) TMTrip* trip;

- (IBAction)tappedDone:(id)sender;

@end
