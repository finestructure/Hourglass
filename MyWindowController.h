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


@interface MyWindowController : NSWindowController
{
		// Main Window
	IBOutlet DBSourceSplitView *sourceSplitView;
	IBOutlet DBListSplitView *listSplitView;
	IBOutlet NSView *sourceViewPlaceholder;
	IBOutlet NSView *contentViewPlaceholder;
	
		// Source View
	IBOutlet NSView *sourceView;
	IBOutlet SourceListTableView *mailboxesTableView;

		// Content View
	IBOutlet NSView *contentView;
    
	IBOutlet NSArrayController *mailboxesArrayController;
	
		// Instance Variables
	NSMutableArray *_mailboxes;
}

- (IBAction)addMailboxAction:(id)sender;

	// Accessor Methods
- (NSMutableArray *)mailboxes;
- (void)setMailboxes:(NSArray *)newMailboxes;


@end
