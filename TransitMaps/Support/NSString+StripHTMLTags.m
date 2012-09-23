//
//  NSString+StripHTMLTags.m
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import "NSString+StripHTMLTags.h"

@implementation NSString (StripHTMLTags)

//credit: http://rudis.net/content/2009/01/21/flatten-html-content-ie-strip-tags-cocoaobjective-c
//got to fix your formatting duder

- (NSString *)stringByStrippingHTML {
	
	NSScanner* theScanner;
	NSString* text = nil;
	NSString* retVal = nil;
	theScanner = [NSScanner scannerWithString:self];
	
	while ([theScanner isAtEnd] == NO) {
		
		// find start of tag
		[theScanner scanUpToString:@"<" intoString:nil] ;
		
		// find end of tag
		[theScanner scanUpToString:@">" intoString:&text] ;
		
		// replace the found tag with a space
		//(you can filter multi-spaces out later if you wish)
		retVal = [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
	} // while //
	
	return retVal;
	
}
@end
