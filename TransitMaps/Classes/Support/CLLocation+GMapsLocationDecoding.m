//
//  CLLocation+GMapsLocationDecoding.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import "CLLocation+GMapsLocationDecoding.h"

@implementation CLLocation (GMapsLocationDecoding)

+ (CLLocation*)locationForGMapsDictionary:(NSDictionary*)dict
{
	if( !dict ) return nil;
	NSString* lat = [dict objectForKey:@"lat"];
	NSString* lng = [dict objectForKey:@"lng"];
	CLLocation* loc = nil;
	if( lat && lng ){
		loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
	}
	return loc;
}

@end
