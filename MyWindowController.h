//
//  MyWindowController.h
//
//  Created by Dave Batton, August 2006.
//  http://www.Mere-Mortal-Software.com/
//
//  Copyright 2006 by Dave Batton. Some rights reserved.
//  http://creativecommons.org/licenses/by/2.5/
//


#import <Cocoa/Cocoa.h>
#import "DBSourceSplitView.h"
#import "DBListSplitView.h"
#import "SourceListTableView.h"


@interface MyWindowController : NSWindowController {
  
	IBOutlet NSView *sourceView;
	IBOutlet NSView *sourceViewPlaceholder;
	IBOutlet NSView *contentView;
	IBOutlet NSView *contentViewPlaceholder;

}

@end
