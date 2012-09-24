//
//  TMSegmentAnnotation.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TMSegmentAnnotation : NSObject<MKAnnotation>
@property NSString* iconURL;
@property NSString* title;
@property NSString* subtitle;
@property CLLocationCoordinate2D coordinate;
@end
