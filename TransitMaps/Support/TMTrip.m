//
//  TMTrip.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <MapKit/MapKit.h>
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
	
	
	
	
	return nil;
}

- (NSArray*) allOverlays
{
	NSMutableArray* overlays = [NSMutableArray arrayWithObject:_overviewPolylineView];
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
