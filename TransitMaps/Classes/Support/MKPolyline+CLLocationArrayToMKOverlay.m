//
//  MKPolyline+CLLocationArrayToMKOverlay.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import "MKPolyline+CLLocationArrayToMKOverlay.h"
#import <CoreLocation/CoreLocation.h>

@implementation MKPolyline (CLLocationArrayToMKOverlay)

+ (MKPolyline*)polylineWithCoordinates:(NSArray*)polylinePoints
{
	CLLocationCoordinate2D coords[[polylinePoints count]];
	CLLocationCoordinate2D* coordsPtr = coords;
	for( CLLocation* loc in polylinePoints){
		*coordsPtr = [loc coordinate];
		coordsPtr++;
	}
	return [MKPolyline polylineWithCoordinates:coords count:[polylinePoints count]];
}

@end
