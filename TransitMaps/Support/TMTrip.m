//
//  TMTrip.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TMTrip.h"
#import "TMTripSegment.h"
#import "TMSegmentAnnotation.h"

@implementation TMTrip
+ (TMTrip*) tripWithRouteData:(NSDictionary*)routeData
{
	TMTrip* trip = [[TMTrip alloc] init];
	NSArray* points = [[[routeData objectForKey:@"overview_polyline"] objectForKey:@"points"] decodePolyLine];
	if( points ){
		[trip setOverviewPolyline:[MKPolyline polylineWithCoordinates:points]];
		[trip setOverviewPolylineView:[[MKPolylineView alloc] initWithPolyline:[trip overviewPolyline]]];
	}
	NSDictionary* legs = [[routeData objectForKey:@"legs"] lastObject];
	[trip setStartLocation:[CLLocation locationForGMapsDictionary:[legs objectForKey:@"start_location"]]];
	[trip setDestinationLocation:[CLLocation locationForGMapsDictionary:[legs objectForKey:@"end_location"]]];
	[trip setDistance:[[legs objectForKey:@"distance"] objectForKey:@"text"]];
	[trip setDuration:[[legs objectForKey:@"duration"] objectForKey:@"text"]];
	[trip setDepartureTime:[[legs objectForKey:@"departure_time"] objectForKey:@"text"]];
	[trip setArrivalTime:[[legs objectForKey:@"arrival_time"] objectForKey:@"text"]];
	[trip setStartAddress:[legs objectForKey:@"start_address"]];
	[trip setDestinationAddress:[legs objectForKey:@"end_address"]];
	NSArray* steps = [legs objectForKey:@"steps"];
	NSMutableArray* segments = [NSMutableArray array];
	for( NSDictionary* step in steps ){
		//less than 150m? skip!
		if( [[[step objectForKey:@"distance"] objectForKey:@"value"] intValue] < 150 && [segments count] > 0 && [steps lastObject] != step ) continue;
		[segments addObject:[TMTripSegment segmentWithMapsData:step]];
	}
	[trip setSegments:segments];
	return trip;
}

- (NSArray*) overviewAnnotations
{
	if( !_overviewAnnotations ){
		MKPointAnnotation* start = [[MKPointAnnotation alloc] init];
		[start setCoordinate:[_startLocation coordinate]];
		[start setTitle:_startAddress];
		[start setSubtitle:_departureTime];
		MKPointAnnotation* end = [[MKPointAnnotation alloc] init];
		[end setTitle:_destinationAddress];
		[end setSubtitle:_arrivalTime];
		[end setCoordinate:[_destinationLocation coordinate]];
		_overviewAnnotations = @[start,end];
	}
	return _overviewAnnotations;
}

- (NSArray*) stepAnnotations
{
	// walk icon: https://maps.gstatic.com/mapfiles/transit/iw/6/walk.png
	// bus icon: https://maps.gstatic.com/mapfiles/transit/iw/6/bus.png
	// rail icon: https://maps.gstatic.com/mapfiles/transit/iw/6/rail.png
	if( !_stepAnnotations ){
		NSMutableArray* annotations = [NSMutableArray array];
		for( TMTripSegment* segment in _segments ){
			TMSegmentAnnotation* annotation = [[TMSegmentAnnotation alloc] init];
			[annotation setTitle:[segment segmentTitle]];
			[annotation setSubtitle:[segment segmentSubtitle]];
			[annotation setIconURL:[segment segmentIconURL]];
			[annotation setCoordinate:[[segment startLocation] coordinate]];
			[annotations addObject:annotation];
		}
		_stepAnnotations = annotations;
	}
	return _stepAnnotations;
}

- (NSArray*)allAnnotations
{
	NSMutableArray* annotations = [NSMutableArray array];
	[annotations addObjectsFromArray:_stepAnnotations];
	[annotations addObjectsFromArray:_overviewAnnotations];
	return annotations;
}

- (NSArray*) allOverlays
{
	NSMutableArray* overlays = [NSMutableArray arrayWithObject:_overviewPolyline];
	for( TMTripSegment* segment in _segments ){
		[overlays addObject:[segment polyline]];
	}
	return overlays;
}

- (MKPolylineView*)viewForOverlay:(id)overlay
{
	if( overlay == _overviewPolyline ) return _overviewPolylineView;
	else{
		for( TMTripSegment* segment in _segments ){
			if( [segment polyline] == overlay ) return [segment polylineView];
		}
	}
	return nil;
}

@end
