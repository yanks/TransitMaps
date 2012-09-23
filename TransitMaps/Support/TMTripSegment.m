//
//  TMTripSegment.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TMTripSegment.h"


@implementation TMTripSegment
+ (TMTripSegment*)segmentWithMapsData:(NSDictionary*)data
{
	TMTripSegment* segment = [[TMTripSegment alloc] init];
	NSString* instructions = [data objectForKey:@"html_instructions"];
	if( !instructions ){
		//toplevel leg object
		NSString* startTime = [[data objectForKey:@"departure_time"] objectForKey:@"text"];
		NSString* endTime = [[data objectForKey:@"arrival_time"] objectForKey:@"text"];
		NSString* travelMode = [data objectForKey:@"travel_mode"];
		if( [travelMode isEqualToString:@"WALKING"]){
			instructions = [NSString stringWithFormat:@"Walk: %@-%@", startTime, endTime];
		}
	}
	else{
		instructions = [instructions stringByStrippingHTML];
	}
	
	[segment setStartLocation:[data objectForKey:@"start_location"]];
	[segment setEndLocation:[data objectForKey:@"end_location"]];
	
	//polyline
	NSDictionary* polylineData = [data objectForKey:@"polyline"];
	if( !polylineData ) polylineData = [data objectForKey:@"overview_polyline"];
	NSString* steps = [polylineData objectForKey:@"points"];
	if( steps ){
		NSArray* polylinePoints = [steps decodePolyLine];
		CLLocationCoordinate2D coords[[polylinePoints count]];
		CLLocationCoordinate2D* coordsPtr = coords;
		for( CLLocation* loc in polylinePoints){
			*coordsPtr = [loc coordinate];
			coordsPtr++;
		}
		[segment setPolyline:[MKPolyline polylineWithCoordinates:coords count:[polylinePoints count]]];
		[segment setPolylineView:[[MKPolylineView alloc] initWithPolyline:[segment polyline]]];
	}
	
	//distance/time
	[segment setDistance:[[data objectForKey:@"distance"] objectForKey:@"text"]];
	[segment setTime:[[data objectForKey:@"duration"] objectForKey:@"text"]];
	
	//steps
	NSArray* stepsData = [data objectForKey:@"steps"];
	if( stepsData ){
		NSMutableArray* steps = [NSMutableArray array];
		for( NSDictionary* step in stepsData ){
			[steps addObject:[TMTripSegment segmentWithMapsData:step]];
		}
		[segment setSteps:steps];
	}
	return segment;
}





@end
