//
//  MKPolyline+CLLocationArrayToMKOverlay.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (CLLocationArrayToMKOverlay)
+ (MKPolyline*)polylineWithCoordinates:(NSArray*)polylinePoints;
@end
