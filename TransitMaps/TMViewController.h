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
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UIButton *swapButtonTapped;
@property (strong, nonatomic) IBOutlet UIView *loaderView;
@property (strong, nonatomic) UITapGestureRecognizer* recognizer;
@property (strong, nonatomic) NSOperationQueue* queue;

@property NSMutableArray* trips;
@property BOOL overviewMode;
@property TMTrip* activeTrip;
@end
