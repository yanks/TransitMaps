//
//  TMViewController.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/22/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TMTrip;

@interface TMViewController : UIViewController<UITextFieldDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//Search View
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;

//Overview
@property (strong, nonatomic) IBOutlet UIView *tripOverviewView;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeOptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *routeLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *routeRightButton;
@property (weak, nonatomic) IBOutlet UIButton *routeDirectionListButton;

- (IBAction)swapAddressButtonTapped:(id)sender;
- (IBAction)overviewClearButtonTapped:(id)sender;
- (IBAction)routeDirectionListButtonTapped:(id)sender;
- (IBAction)routeLeftButtonTapped:(id)sender;
- (IBAction)routeRightButtonTapped:(id)sender;

- (void)setDirectionsRequest:(MKDirectionsRequest*)request;

@end
