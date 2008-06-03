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
  IBOutlet NSView* taskView; // full task view, incl predicate editor
  IBOutlet NSView* customerView;
  IBOutlet NSView* projectView;
  IBOutlet NSView* taskDetailView; // task detail view, below pred. editor
  IBOutlet NSWindow* mainWindow;
  IBOutlet NSView* _savePanelAccessory; // '_' prevents clash with NSDocument's member
  IBOutlet NSPopUpButton* fileTypeSelector;
  IBOutlet NSButton* fillDaysSelector;
  IBOutlet NSPredicateEditor* predicateEditor;
  NSSavePanel* savePanel;
  NSInteger previousRowCount;
  
}

- (void)ensure:(id)groups
  containsName:(NSString*)groupName
   withImage:(NSString*)imageName;

- (void)exportToText:(NSString*)filename fillDays:(BOOL)fillDays;
- (void)exportToXML:(NSString*)filename fillDays:(BOOL)fillDays;
- (void)resizePredicateEditor;
- (void)showView:(NSView*)aView;

// IB actions

- (void)newTask:(id)sender;
- (void)setStartToNow:(id)sender;
- (void)setEndToNow:(id)sender;
- (void)applyGroupFilter;
- (void)export:(id)sender;
- (void)fileTypeSelection:(id)sender;

// delegates

- (IBAction)predicateEditorChanged:(id)sender;

@end
