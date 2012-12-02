//
//  TMTripSegment.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	TMSegmentTypeWalking=0,
	TMSegmentTypeTransit=1
} TMSegmentType;

@class CLLocation, MKPolyline, MKPolylineView;

@interface TMTripSegment : NSObject
@property NSString* textDirections;
@property NSString* distance;
@property NSString* time;
@property CLLocation* startLocation;
@property CLLocation* endLocation;
@property NSArray* steps; //TMTripSegments
@property MKPolyline* polyline;
@property MKPolylineView* polylineView;
@property TMSegmentType segmentType;
@property NSString* segmentTitle;
@property NSString* segmentSubtitle;
@property NSString* segmentIconURL;
@property NSString* instructions;
@property NSString* transitDestination;

+ (TMTripSegment*)segmentWithMapsData:(NSDictionary*)data;

@end
