//
//  SourceListImageCell.m
//  TableTester
//
//  Created by Matt Gemmell on Mon Dec 29 2003.
//  Copyright (c) 2003 Scotland Software. All rights reserved.
//


#import "SourceListImageCell.h"
#import "CTGradient.h"


@implementation SourceListImageCell




- (id)init
{
    if (self = [super init]) {
        [self setImageAlignment:NSImageAlignTop];
        
        return self;
    }
    return nil;
}




- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[controlView lockFocus];

		/* Determine whether we should draw a blue or grey gradient. */
		/* We will automatically redraw when our parent view loses/gains focus, or when our parent window loses/gains main/key status. */
	if ([self isHighlighted]) {
		if (([[controlView window] firstResponder] == controlView) && 
				[[controlView window] isMainWindow] &&
				[[controlView window] isKeyWindow]) {
			[[CTGradient sourceListSelectedGradient] fillRect:cellFrame angle:270];
		} else {
			[[CTGradient sourceListUnselectedGradient] fillRect:cellFrame angle:270];
		}
	}
	
	/* Now draw our image. */
	NSImage *img = [self image];
	NSSize imgSize = [img size];
	NSPoint drawPoint = NSMakePoint(cellFrame.origin.x + (floor(cellFrame.size.width / 2) - floor(imgSize.width / 2)), cellFrame.origin.y + cellFrame.size.height);
	
	// Fine tuning.
	drawPoint.x += 0;
	drawPoint.y -= 1;

	[img compositeToPoint:drawPoint fromRect:NSMakeRect(0, 0, imgSize.width, imgSize.height) operation:NSCompositeSourceOver fraction:1.0];
	
	[controlView unlockFocus];
}

@end
