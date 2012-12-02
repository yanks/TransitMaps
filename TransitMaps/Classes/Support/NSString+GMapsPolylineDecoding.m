//
//  NSString+GMapsPolylineDecoding.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "NSString+GMapsPolylineDecoding.h"

@implementation NSString (GMapsPolylineDecoding)
//Credit: http://icodeapps.blogspot.com/2011/04/google-map-directions-api-objective-c.html
-(NSMutableArray *)decodePolyLine {
	NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[self length]];
	[encoded appendString:self];
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
															options:NSLiteralSearch
																range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	CGFloat lat = 0.0f;
	CGFloat lng = 0.0f;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			if (index >= len) {
				b = 0;
			}
			else{
				b = [encoded characterAtIndex:index++] - 63;
				result |= (b & 0x1f) << shift;
				shift += 5;
			}
		} while (b >= 0x20);
		CGFloat dlat = (result & 1) ? ~(result >> 1) : (result >> 1);
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			if (index >= len) {
				b = 0;
			}
			else{
				b = [encoded characterAtIndex:index++] - 63;
				result |= (b & 0x1f) << shift;
				shift += 5;
			}
		} while (b >= 0x20);
		CGFloat dlng = (result & 1) ? ~(result >> 1) : (result >> 1);
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		//          printf("[%f,", [latitude doubleValue]);
		//          printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	return array;
}

@end
