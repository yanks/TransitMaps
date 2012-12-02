//
//  TMTrip.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MKPolyline, MKPolylineView;

@interface TMTrip : NSObject
@property MKPolyline* overviewPolyline;
@property MKPolylineView* overviewPolylineView;
@property NSString* departureTime;
@property NSString* arrivalTime;
@property NSString* distance;
@property NSString* duration;
@property CLLocation* startLocation;
@property CLLocation* destinationLocation;
@property NSString* startAddress;
@property NSString* destinationAddress;
@property NSArray* segments;
@property(nonatomic) NSArray* overviewAnnotations;
@property(nonatomic) NSArray* stepAnnotations;

+ (TMTrip*) tripWithRouteData:(NSDictionary*)routeData;
- (NSArray*) allOverlays;
- (MKPolylineView*)viewForOverlay:(id)overlay;
- (NSArray*) overviewAnnotations;
- (NSArray*) stepAnnotations;
- (NSArray*) allAnnotations;
@end
