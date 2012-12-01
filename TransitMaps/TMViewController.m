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
#import "MBProgressHUD.h"

@interface TMViewController (){
	NSTimeInterval _startTime;
}
@property(strong, nonatomic) NSMutableArray* trips;
@property(assign, nonatomic) BOOL overviewMode;
@property(strong, nonatomic) TMTrip* activeTrip;

@property (strong, nonatomic) UITapGestureRecognizer* recognizer;
@property (strong, nonatomic) NSOperationQueue* queue;
@end

@implementation TMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[_mapView setShowsUserLocation:YES];
	[_mapView setScrollEnabled:YES];
	_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
	_queue = [[NSOperationQueue alloc] init];
	_startTime = [[NSDate date] timeIntervalSince1970];
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
	NSString* baseFormat = @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&departure_time=%lld&mode=transit&alternatives=true&sensor=true";
	if( [[_fromTextField text] isEqualToString:@"Current Location"] || [[_toTextField text] isEqualToString:@"Current Location"] ){
		UITextField* toSet = [[_fromTextField text] isEqualToString:@"Current Location"] ? _fromTextField : _toTextField;
		CLGeocoder* geocoder = [[CLGeocoder alloc] init];
		[geocoder reverseGeocodeLocation:[[_mapView userLocation] location] completionHandler:^(NSArray* placemarks, NSError* err){
			dispatch_async(dispatch_get_main_queue(), ^{			
				if( err || [placemarks count] == 0 ){
					UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error finding your location. Please try again." delegate:nil cancelButtonTitle:@"Darn." otherButtonTitles:nil];
					[alert show];
				}
				else{
					CLPlacemark* place = [placemarks objectAtIndex:0];
					NSString* fromString = [NSString stringWithFormat:@"%@ %@, %@, %@ %@", [place subThoroughfare], [place thoroughfare], [place locality], [place administrativeArea], [place subAdministrativeArea]];
					[toSet setText:fromString];
					[self performSearch];
				}
			});
		}];
		return;
	}
	NSString* from = [[_fromTextField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString* to = [[_toTextField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSString* url = [NSString stringWithFormat:baseFormat, from, to, (long long)now+60];
	[MBProgressHUD showHUDAddedTo:[self view] animated:YES];
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:_queue completionHandler:^(NSURLResponse* resp, NSData* data, NSError* err){
		
		
		err = nil;
		NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
		NSArray* routes = [result objectForKey:@"routes"];
		if( err || !routes || [routes count] == 0 ){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self failWithError:err];
			});
			return;
		}
		_trips = [NSMutableArray array];
		for( NSDictionary* route in routes ){
			[_trips addObject:[TMTrip tripWithRouteData:route]];
		}
		
		_overviewMode = YES;
		
		[self setActiveTrip:[_trips objectAtIndex:0]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setupOverview];
			[MBProgressHUD hideHUDForView:[self view] animated:YES];
		});
	}];
}

- (void)failWithError:(NSError*)err
{
	[MBProgressHUD hideHUDForView:[self view] animated:YES];

	//FIXME: handle error condition
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error finding directions between these locations." delegate:nil cancelButtonTitle:@"Darn." otherButtonTitles:nil];
	[alert show];
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
	[self clearOverlays];
	MKPolylineView* lineView = [_activeTrip overviewPolylineView];
	[lineView setStrokeColor:[UIColor colorWithRed:.241 green:.6 blue:.992 alpha:1.0]];
	[lineView setLineCap:kCGLineCapButt];
	[lineView setLineWidth:0];
	[_mapView addOverlay:[_activeTrip overviewPolyline]];
	
	[_mapView addAnnotations:[_activeTrip overviewAnnotations]];
	[_mapView addAnnotations:[_activeTrip stepAnnotations]];
	
	CLLocationCoordinate2D startLocation = [[_activeTrip startLocation] coordinate];
	CLLocationCoordinate2D endLocation = [[_activeTrip destinationLocation] coordinate];
	
	//find center
	CLLocationDegrees lowX = startLocation.latitude <= endLocation.latitude ? startLocation.latitude : endLocation.latitude;
	CLLocationDegrees highX = startLocation.latitude > endLocation.latitude ? startLocation.latitude : endLocation.latitude;
	CLLocationDegrees lowY = startLocation.longitude <= endLocation.longitude ? startLocation.longitude : endLocation.longitude;
	CLLocationDegrees highY = startLocation.longitude > endLocation.longitude ? startLocation.longitude : endLocation.longitude;
	
	CLLocationDegrees latDelta = highX-lowX;
	CLLocationDegrees lngDelta = highY-lowY;
	
	CLLocationCoordinate2D center = CLLocationCoordinate2DMake((highX-((highX-lowX)/2)), (highY-((highY-lowY)/2)));
	MKCoordinateSpan span = MKCoordinateSpanMake(latDelta+.03, lngDelta+.03);
	[_mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
	
	[_searchView removeFromSuperview];
	
	[_destinationLabel setText:[_activeTrip destinationAddress]];
	[_timeDistanceLabel setText:[NSString stringWithFormat:@"%@ - %@", [_activeTrip distance], [_activeTrip duration]]];
	[_routeOptionsLabel setText:[NSString stringWithFormat:@"Route %d of %d", [_trips indexOfObject:_activeTrip]+1, [_trips count]]];
	[[self view] addSubview:_tripOverviewView];
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	if( [[NSDate date] timeIntervalSince1970] - _startTime < 5 )
		[_mapView setRegion:MKCoordinateRegionMake([[_mapView userLocation] coordinate], MKCoordinateSpanMake(.1, .1))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swapAddressButtonTapped:(id)sender {
	NSString* tmp = [_fromTextField text];
	[_fromTextField setText:[_toTextField text]];
	[_toTextField setText: tmp];
}

- (IBAction)overviewClearButtonTapped:(id)sender {
	[self clearOverlays];
	[_tripOverviewView removeFromSuperview];
	[[self view] addSubview:_searchView];
	[_fromTextField becomeFirstResponder];
}

- (IBAction)routeDirectionListButtonTapped:(id)sender {
}

- (void)incrementActiveTripBy:(int)inc
{
	int tripIndex = [_trips indexOfObject:_activeTrip];
	tripIndex+=inc;
	if( tripIndex < 0 ) tripIndex = [_trips count] - 1;
	if( tripIndex == [_trips count] ) tripIndex = 0;
	_activeTrip = [_trips objectAtIndex:tripIndex];
	[self setupOverview];
}

- (IBAction)routeLeftButtonTapped:(id)sender {
	[self incrementActiveTripBy:-1];
}

- (IBAction)routeRightButtonTapped:(id)sender {
	[self incrementActiveTripBy:1];
}
@end
