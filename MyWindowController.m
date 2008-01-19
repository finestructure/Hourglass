//
//  MyWindowController.m
//
//  Created by Dave Batton, August 2006.
//  http://www.Mere-Mortal-Software.com/
//
//  Copyright 2006 by Dave Batton. Some rights reserved.
//  http://creativecommons.org/licenses/by/2.5/
//
//  The Mailbox and Email classes used in this example are from the Introduction to Cocoa Bindings tutorial by Scott Stevenson. The full tutorial is available at CocoaDevCentral.com:
//  http://www.cocoadevcentral.com/articles/000080.php
//


#import "MyWindowController.h"
#import "Email.h"
#import "Mailbox.h"


@implementation MyWindowController




- (id) init
{
    if (self = [super init]) {
        _mailboxes = [[NSMutableArray alloc] init];

			// Add a few mailboxes and emails just for the demo.
		Mailbox *sampleMailbox1 = [[[Mailbox alloc] init] autorelease];
		[sampleMailbox1 setTitle:@"Inbox"];
		Email *sampleEmail1 = [[[Email alloc] init] autorelease];
		[sampleEmail1 setSubject:@"Dynamic Stock Report!!!"];
		Email *sampleEmail2 = [[[Email alloc] init] autorelease];
		[sampleEmail2 setSubject:@"Your PayPal Account Has Been Violated"];
		Email *sampleEmail3 = [[[Email alloc] init] autorelease];
		[sampleEmail3 setSubject:@"Real Replica Rolex Watches!"];
		Email *sampleEmail4 = [[[Email alloc] init] autorelease];
		[sampleEmail4 setSubject:@"Viagra for LESS"];
		NSArray *emails = [NSArray arrayWithObjects:sampleEmail1,
													sampleEmail2,
													sampleEmail3,
													sampleEmail4,
													nil];
		[sampleMailbox1 setEmails:emails];

		Mailbox *sampleMailbox2 = [[[Mailbox alloc] init] autorelease];
		[sampleMailbox2 setTitle:@"Outbox"];

		Mailbox *sampleMailbox3 = [[[Mailbox alloc] init] autorelease];
		[sampleMailbox3 setTitle:@"Drafts"];

		NSArray *sampleData = [NSArray arrayWithObjects:sampleMailbox1,
														sampleMailbox2,
														sampleMailbox3,
														nil];
		[self setMailboxes:sampleData];	
	}
    return self;
}




- (void) dealloc
{
    [_mailboxes release];
    [super dealloc];
}




- (void)awakeFromNib
{
		// This is required when subclassing NSWindowController.
	[self setWindowFrameAutosaveName:@"MainWindow"];
	
		// This will center the main window if there's no stored position for it.
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"NSWindow Frame MainWindow"] == nil)
		[[self window] center];

		// Set the splitters' autosave names.
	[sourceSplitView setPositionAutosaveName:@"SourceSplitter"];
	[sourceSplitView setPositionAutosaveName:@"ListSplitter"];

		// Place the source list view in the left panel.
	[sourceView setFrameSize:[sourceViewPlaceholder frame].size];
	[sourceViewPlaceholder addSubview:sourceView];

		// Place the content view in the right panel.
	[contentView setFrameSize:[contentViewPlaceholder frame].size];
	[contentViewPlaceholder addSubview:contentView];
}




- (IBAction)addMailboxAction:(id)sender
{
	[[self window] makeFirstResponder:mailboxesTableView];
	[mailboxesArrayController add:sender];
}




#pragma mark -
#pragma mark Accessor Methods

- (NSMutableArray *) mailboxes
{
    return _mailboxes;
}




- (void) setMailboxes:(NSArray *)newMailboxes
{
    if (_mailboxes != newMailboxes) {
        [_mailboxes autorelease];
        _mailboxes = [[NSMutableArray alloc] initWithArray: newMailboxes];
    }
}




@end
