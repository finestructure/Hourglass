//
//  DBSourceView.m
//
//  Created by Dave Batton, August 2006.
//  http://www.Mere-Mortal-Software.com/
//
//  Copyright 2006 by Dave Batton. Some rights reserved.
//  http://creativecommons.org/licenses/by/2.5/
//
//  This class is a subclass of NSView to be used for the source (left) side of an Apple Mail (Tiger) style interface. It changes the cursor to the left/right splitter cursor when its over the splitter thumb image (DBSourceSplitViewThumb) at the bottom of the window, and it also handles tracking for the splitter when the thumb is clicked and dragged.
//


#define MIN_WIDTH 80
#define BOTTOM_BAR_HEIGHT 23
#define THUMB_RECT NSMakeRect(NSWidth([self frame]) - 17, 0, 17, BOTTOM_BAR_HEIGHT)

#import "DBSourceView.h"


@implementation DBSourceView




- (void)resetCursorRects
{
		// Change the cursor to the resize cursor when it's over the resize thumb.
	[super resetCursorRects];
	NSRect resizeThumbRect = THUMB_RECT;
	[self addCursorRect:resizeThumbRect cursor:[NSCursor resizeLeftRightCursor]];
}




- (void)mouseDown:(NSEvent *)event
{
	float deltaX;
	NSPoint currentMouseLoc;
	NSPoint startingMouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];

	NSRect startingViewRect = [self frame];
	
	NSRect resizeThumbRect = THUMB_RECT;
	
	BOOL isInside = [self mouse:startingMouseLoc inRect:resizeThumbRect];
    BOOL keepOn = isInside;
	NSRect rect;
		
	if (!keepOn) {
		[super mouseDown:event];
		return;
	}
	
    while (keepOn) {
        event = [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];

		switch ([event type]) {
			case NSLeftMouseDragged:
				currentMouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
				deltaX = startingMouseLoc.x - currentMouseLoc.x;
				rect = startingViewRect;
				rect.size.width -= deltaX;
				if (rect.size.width < MIN_WIDTH)
					rect.size.width = MIN_WIDTH;
				[[self superview]setFrame:rect];
				[[[self superview]superview] display];
				break;
			case NSLeftMouseUp:
				keepOn = NO;
				break;
			default:
				[super mouseDown:event];
				break;
		}
    }
	return;
}




@end
