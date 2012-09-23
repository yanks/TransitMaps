//
//  NSString+StripHTMLTags.h
//  TransitMaps
//
//  Created by Jeff Forbes on 9/23/12.
//  Copyright (c) 2012 ER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StripHTMLTags)
- (NSString *)stringByStrippingHTML;
@end
