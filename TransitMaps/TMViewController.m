//
//  TMViewController.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/22/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TMViewController.h"
#import "TMTripSegment.h"
#import "TMTrip.h"
#import "TMSegmentAnnotation.h"
#import "TMAnnotationImageHelper.h"

@interface TMViewController ()

@end

@implementation TMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[_mapView setShowsUserLocation:YES];
	[_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(40.7252, -73.99768), MKCoordinateSpanMake(.1, .1))];
	[_mapView setScrollEnabled:YES];
	_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
	[_loaderView removeFromSuperview];
	_queue = [[NSOperationQueue alloc] init];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[_mapView addGestureRecognizer:_recognizer];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[_mapView removeGestureRecognizer:_recognizer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	if( textField == _fromTextField ){
		[_toTextField becomeFirstResponder];
	}
	if( _toTextField == textField ) [self performSearch];
	
	return NO;
}

- (void)performSearch
{
	
	[self clearOverlays];
	
	//example url: http://maps.googleapis.com/maps/api/directions/json?origin=Brooklyn&destination=Queens&sensor=false&departure_time=1343605500&mode=transit
	NSString* baseFormat = @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&departure_time=%lld&mode=transit&alternatives=true";
	NSString* from = [[_fromTextField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString* to = [[_toTextField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSString* url = [NSString stringWithFormat:baseFormat, from, to, (long long)now+60];
	NSLog(@"%@", url);
	[[self view] addSubview:_loaderView];
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:_queue completionHandler:^(NSURLResponse* resp, NSData* data, NSError* err){
		
		
		NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		NSArray* routes = [result objectForKey:@"routes"];
		_trips = [NSMutableArray array];
		for( NSDictionary* route in routes ){
			[_trips addObject:[TMTrip tripWithRouteData:route]];
		}
		
//		TMTrip* first = [_trips objectAtIndex:0];
//		
//		MKPolylineView* view = [[MKPolylineView alloc] initWithPolyline:[first overviewPolyline]];
//		[view setStrokeColor:[UIColor colorWithRed:.241 green:.6 blue:.992 alpha:1.0]];
//		[view setLineCap:kCGLineCapButt];
//		MKPolyline* polyline = [first overviewPolyline];
		
		_overviewMode = YES;
		
		[self setActiveTrip:[_trips objectAtIndex:0]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setupOverview];
			[_loaderView removeFromSuperview];
		});
	}];
}

- (void)clearOverlays
{
	for( TMTrip* trip in _trips ){
		[_mapView removeOverlays:[trip allOverlays]];
		[_mapView removeAnnotations:[trip allAnnotations]];
	}
}

- (void)setupOverview
{
//	for( TMTrip* trip in _trips ){
//		if( trip == _activeTrip ) continue;
//		[_mapView addOverlay:[trip overviewPolyline]];
//		MKPolylineView* lineView = [trip overviewPolylineView];
//		[lineView setStrokeColor:[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0]];
//		[lineView setLineCap:kCGLineCapButt];
//		[lineView setLineWidth:0];
//	}
	MKPolylineView* lineView = [_activeTrip overviewPolylineView];
	[lineView setStrokeColor:[UIColor colorWithRed:.241 green:.6 blue:.992 alpha:1.0]];
	[lineView setLineCap:kCGLineCapButt];
	[lineView setLineWidth:0];
	[_mapView addOverlay:[_activeTrip overviewPolyline]];
	
	[_mapView addAnnotations:[_activeTrip overviewAnnotations]];
	[_mapView addAnnotations:[_activeTrip stepAnnotations]];
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
{
	MKPolylineView* view = nil;
	for( TMTrip* trip in _trips ){
		view = [trip viewForOverlay:overlay];
		if( view ) break;
	}
	return view;
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKPointAnnotation class]]){
		static NSString* PinAnnotationIdentifier = @"pinAnnotationIdentifer";
		MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[mapView dequeueReusableAnnotationViewWithIdentifier:PinAnnotationIdentifier];
		
		if (!pinView)
		{
			// if an existing pin view was not available, create one
			pinView = [[MKPinAnnotationView alloc]
																						 initWithAnnotation:annotation reuseIdentifier:PinAnnotationIdentifier];
			pinView.animatesDrop = NO;
			pinView.canShowCallout = YES;
		}
		
		if( [[_activeTrip overviewAnnotations] objectAtIndex:0] == annotation ){
			pinView.pinColor = MKPinAnnotationColorGreen;
		}
		else pinView.pinColor = MKPinAnnotationColorRed;
		
		//			customPinView.canShowCallout = YES;
		
		// add a detail disclosure button to the callout which will open a new view controller page
		//
		// note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
		//  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
		//
		//			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		//			[rightButton addTarget:self
		//											action:@selector(showOverviewDetails:)
		//						forControlEvents:UIControlEventTouchUpInside];
		//			customPinView.rightCalloutAccessoryView = rightButton;
		
		return pinView;
	}
	else if( [annotation isKindOfClass:[TMSegmentAnnotation class]]){
		static NSString* SegmentAnnotationIdentifier = @"SegmentAnnotationIdentifer";
		MKAnnotationView* segmentView = (MKPinAnnotationView *)
		[mapView dequeueReusableAnnotationViewWithIdentifier:SegmentAnnotationIdentifier];
		if( !segmentView ){
			// if an existing pin view was not available, create one
			segmentView = [[MKPinAnnotationView alloc]
																						initWithAnnotation:annotation reuseIdentifier:SegmentAnnotationIdentifier];
			segmentView.canShowCallout = YES;
		}
		if( [(TMSegmentAnnotation*)annotation iconURL] ){
			[segmentView setImage:[TMAnnotationImageHelper imageForIconURL:[(TMSegmentAnnotation*)annotation iconURL]]];
		}
		return segmentView;
	}
	return nil;
}

- (void)mapTapped:(id)sender
{
	[_fromTextField resignFirstResponder];
	[_toTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
