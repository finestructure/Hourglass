//
//  DBBottomButton.m
//  Inspire Me
//
//  Created by Dave Batton, August 2006.
//  http://www.Mere-Mortal-Software.com/
//
//  Copyright 2006 by Dave Batton. Some rights reserved.
//  http://creativecommons.org/licenses/by/2.5/
//

#import "DBBottomButton.h"


@implementation DBBottomButton


	// The NSButton class just draws the button 50% lighter when disabled. It looks better if instead a different image is used.
- (void)drawRect:(NSRect)aRect {
	if ([self isEnabled] ==  YES) {
		[super drawRect:aRect];
	} else {
		NSString *buttonName = [NSString stringWithFormat:@"%@_Disabled", [[self image] name]];
		NSImage *disabledImage = [NSImage imageNamed:buttonName];
		[disabledImage setFlipped: YES];
		NSRect srcRect;
		srcRect.origin = NSZeroPoint;
		srcRect.size = [disabledImage size];
		[disabledImage drawInRect:aRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0 ];
	}
}


@end
