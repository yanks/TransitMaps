//
//  CLLocation+GMapsLocationDecoding.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (GMapsLocationDecoding)
+ (CLLocation*)locationForGMapsDictionary:(NSDictionary*)dict;
@end
