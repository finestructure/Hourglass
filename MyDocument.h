//
//  MyDocument.h
//  PdbX
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyDocument : NSPersistentDocument {
  
	IBOutlet NSView *sourceView;
	IBOutlet NSView *sourceViewPlaceholder;
	IBOutlet NSView *contentView;
	IBOutlet NSView *contentViewPlaceholder;
  IBOutlet NSArrayController* tasksController;
  IBOutlet NSArrayController* groupsController;
  
}

- (void)ensure:(id)groups
  containsName:(NSString*)groupName;

@end
