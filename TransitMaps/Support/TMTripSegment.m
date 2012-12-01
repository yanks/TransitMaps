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
#import "TMAnnotationImageHelper.h"

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
	
	[segment setStartLocation:[CLLocation locationForGMapsDictionary:[data objectForKey:@"start_location"]]];
	[segment setEndLocation:[CLLocation locationForGMapsDictionary:[data objectForKey:@"end_location"]]];
	
	//polyline
	NSDictionary* polylineData = [data objectForKey:@"polyline"];
	if( !polylineData ) polylineData = [data objectForKey:@"overview_polyline"];
	NSString* steps = [polylineData objectForKey:@"points"];
	if( steps && [steps length] < 20000 ){ //sanity on the polyline
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
	
	//transit data
	NSDictionary* transitData = [data objectForKey:@"transit_details"];
	if( !transitData ){
		[segment setSegmentType:TMSegmentTypeWalking];
		[segment setSegmentTitle:@"Walk"];
		[segment setSegmentSubtitle:[NSString stringWithFormat:@"%@ - %@", [segment time], [segment distance]]];
		[segment setSegmentIconURL:@"http://maps.gstatic.com/mapfiles/transit/iw/4/walk.png"];
		[TMAnnotationImageHelper imageForIconURL:[segment segmentIconURL]];
	}
	else{
		NSString* shortName = [[transitData objectForKey:@"line"] objectForKey:@"short_name"];
		if( shortName ){
			[segment setSegmentTitle:[NSString stringWithFormat:@"%@ - %@", [[transitData objectForKey:@"line"] objectForKey:@"short_name"], [[transitData objectForKey:@"line"] objectForKey:@"name"]]];
		}
		else{
			[segment setSegmentTitle:[[transitData objectForKey:@"line"] objectForKey:@"name"]];
		}

		[segment setSegmentSubtitle:[NSString stringWithFormat:@"Depart: %@", [[transitData objectForKey:@"departure_time"] objectForKey:@"text"]]];
		
		NSString* iconURLWithoutProtocol = [[transitData objectForKey:@"line"] objectForKey:@"icon"];
		if( !iconURLWithoutProtocol ){
			//vehicle?
			iconURLWithoutProtocol = [[[transitData objectForKey:@"line"] objectForKey:@"vehicle"] objectForKey:@"icon"];
		}
		NSString* icon = [NSString stringWithFormat:@"https:%@", iconURLWithoutProtocol];
		[segment setSegmentIconURL:[icon stringByReplacingOccurrencesOfString:@"/iw/6" withString:@"/iw/4"]];

		[TMAnnotationImageHelper imageForIconURL:[segment segmentIconURL]];
	}
	return segment;
}





@end
