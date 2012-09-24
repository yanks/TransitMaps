//
//  TMAnnotationImageHelper.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/24/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import "TMAnnotationImageHelper.h"

@implementation TMAnnotationImageHelper

+ (UIImage*)imageForIconURL:(NSString*)url
{
	if( !url ) return nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	UIImage* result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", basePath, [url lastPathComponent]]];
	
	NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	if( !imgData ) return nil;
	UIImage* img = [UIImage imageWithData:imgData];
	if( !img ) return nil;
	
	UIImage* bg = [UIImage imageNamed:@"annotationPoint.png"];
	UIGraphicsBeginImageContext([bg size]);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, bg.size.height);
	CGContextConcatCTM(ctx, flipVertical);
	
	CGContextDrawImage(ctx, CGRectMake(0, 0, bg.size.width, bg.size.height), [bg CGImage]);
	CGContextDrawImage(ctx, CGRectMake(3, 8, img.size.width, img.size.height), [img CGImage]);
	
	result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	NSData* data = UIImagePNGRepresentation(result);
	
	[data writeToFile:[NSString stringWithFormat:@"%@/%@", basePath, [url lastPathComponent]] atomically:YES];
	
	return result;
}

@end
