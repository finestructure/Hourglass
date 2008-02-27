//
//  MyDocument.h
//  Hourglass
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyDocument : NSPersistentDocument {
  
	IBOutlet NSView *sourceView;
	IBOutlet NSView *sourceViewPlaceholder;
	IBOutlet NSView *contentViewPlaceholder;
  IBOutlet NSArrayController* tasksController;
  IBOutlet NSArrayController* groupsController;
  IBOutlet NSTableView* contentList;
	IBOutlet NSView* taskView;
  IBOutlet NSView* customerView;
  IBOutlet NSView* projectView;
  IBOutlet NSWindow* mainWindow;
  IBOutlet NSView* fileTypeAccessory;
  IBOutlet NSPopUpButton* fileTypeSelector;
  NSSavePanel* savePanel;
  
}

- (void)ensure:(id)groups
  containsName:(NSString*)groupName
   withImage:(NSString*)imageName;

- (void)exportToText:(NSString*)filename;
- (void)exportToXML:(NSString*)filename;


// IB actions

- (void)newTask:(id)sender;
- (void)setStartToNow:(id)sender;
- (void)setEndToNow:(id)sender;
- (void)showTaskView;
- (void)showCustomerView;
- (void)showProjectView;
- (void)applyGroupFilter;
- (void)export:(id)sender;
- (void)fileTypeSelection:(id)sender;

@end
