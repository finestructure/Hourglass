//
//  MyDocument.m
//  Hourglass
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"

#import "Group.h"
#import "Task.h"

@implementation MyDocument

// ----------------------------------------------------------------------

- (id)init {
  self = [super init];
  if (self != nil) {
    // initialization code
  }
  return self;
}

// ----------------------------------------------------------------------

- (NSString *)windowNibName {
    return @"MyDocument";
}

// ----------------------------------------------------------------------

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
  [super windowControllerDidLoadNib:windowController];

  [contentList setDelegate:self];
  
  // Place the source list view in the left panel.
	[sourceView setFrameSize:[sourceViewPlaceholder frame].size];
	[sourceViewPlaceholder addSubview:sourceView];
  
  [taskView setWantsLayer:YES];
  [customerView setWantsLayer:YES];
  [projectView setWantsLayer:YES];
  
  [self showView:taskView];
  
  // configure predicate editor
  [[predicateEditor enclosingScrollView] setHasVerticalScroller:NO];
  previousRowCount = 3;
  [predicateEditor addRow:self];
  
  // Set up the default groups
  {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:@"Group" 
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *groups = [moc executeFetchRequest:request error:&error];
    [self ensure:groups containsName:@"Current Month" withImage:@"Task"];
    [self ensure:groups containsName:@"Current Week" withImage:@"Task"];
    [self ensure:groups containsName:@"Last Month" withImage:@"Task"];
    [self ensure:groups containsName:@"All" withImage:@"Task"];
    [self ensure:groups containsName:@"Customers" withImage:@"Customer"];
    [self ensure:groups containsName:@"Projects" withImage:@"Folder"];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"sortIndex"
                                                       ascending:YES];
    [groupsController setSortDescriptors:[NSArray arrayWithObject:sd]];

    // clear the undo manager and change count for the document such that
    // untitled documents start with zero unsaved changes
    [moc processPendingChanges];
    [[moc undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
  }

  // set up observing
  {
    [groupsController addObserver:self 
                       forKeyPath:@"selection" 
                          options:NSKeyValueObservingOptionNew
                          context:NULL];

    [[NSNotificationCenter defaultCenter] 
     addObserver:self  
     selector:@selector(objectsChangedInContext:)  
     name:NSManagedObjectContextObjectsDidChangeNotification 
     object:[self managedObjectContext]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(textDidEndEditing:)
     name:NSControlTextDidEndEditingNotification
     object:contentList];
  }
  
  // set up content view sorting
  {
    NSSortDescriptor* 
    sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"startDate"
                                            ascending:NO] autorelease];
    [tasksController setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
  }
  
  // set up file type selector
  {
    [fileTypeSelector addItemWithTitle:@"txt"];
    [fileTypeSelector addItemWithTitle:@"xml"];
  }
}

// ----------------------------------------------------------------------

- (NSString *)displayName {
#ifdef DEBUG_BUILD
  return [NSString stringWithFormat:@"%@ (Debug)", [super displayName]];
#else
  return [super displayName];
#endif
}

// ----------------------------------------------------------------------

- (void)ensure:(id)groups
  containsName:(NSString*)groupName
   withImage:(NSString*)imageName {
  static int sortIndex = 0;
  
  if (groups == nil) return;
  
  NSPredicate* p = [NSPredicate 
                    predicateWithFormat:@"name like %@", groupName];
  NSArray* g1 = [groups filteredArrayUsingPredicate:p];
  if ([g1 count] == 0) {
    id g = [NSEntityDescription 
            insertNewObjectForEntityForName:@"Group"
            inManagedObjectContext:[self managedObjectContext]];
    [g setValue:groupName forKey:@"name"];
    [g setValue:[[NSImage imageNamed:imageName] TIFFRepresentation]
         forKey:@"icon"];
    [g setValue:[NSNumber numberWithInt:sortIndex] forKey:@"sortIndex"];
    ++sortIndex;
  }
}

// ----------------------------------------------------------------------

- (void)newTask:(id)sender {
  id t = [NSEntityDescription 
          insertNewObjectForEntityForName:@"Task"
          inManagedObjectContext:[self managedObjectContext]];
  [tasksController addObject:t];
  [self applyGroupFilter];
}

// ----------------------------------------------------------------------

- (void)setStartToNow:(id)sender {
  id t = [tasksController selection];
  [t setValue:[NSDate date] forKey:@"startDate"];
}

// ----------------------------------------------------------------------

- (void)setEndToNow:(id)sender {
  id t = [tasksController selection];
  [t setValue:[NSDate date] forKey:@"endDate"];
}

// ----------------------------------------------------------------------

- (NSDate*)dateWithFirstOfMonthFor:(NSDate*)date {
  NSCalendar* cal = [NSCalendar currentCalendar];
  unsigned dateFlags = ( NSYearCalendarUnit 
                        | NSMonthCalendarUnit 
                        | NSDayCalendarUnit );
  NSDateComponents* dateComponents = [cal components:dateFlags
                                            fromDate:date];
  [dateComponents setDay:1];
  return [cal dateFromComponents:dateComponents];
}

// ----------------------------------------------------------------------

- (NSDate*)dmyForDate:(NSDate*)date {
  NSCalendar* cal = [NSCalendar currentCalendar];
  unsigned dateFlags = ( NSYearCalendarUnit 
                        | NSMonthCalendarUnit 
                        | NSDayCalendarUnit );
  NSDateComponents* dateComponents = [cal components:dateFlags
                                            fromDate:date];
  return [cal dateFromComponents:dateComponents];
}

// ----------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
  if (object == groupsController 
      && [keyPath isEqual:@"selection"]) {
    [self applyGroupFilter];
  }
}

// ----------------------------------------------------------------------

- (void)objectsChangedInContext:(NSNotification *)info {
  NSSet *inserted = nil;
  if ((inserted = [[info userInfo]  
                   objectForKey:NSInsertedObjectsKey]) != nil) {
    if ([[inserted anyObject] class] == [Task class]) {
      NSString* groupName = [[groupsController selection] valueForKey:@"name"];
      if ( ! ([groupName isEqualTo:@"All"]
              || [groupName isEqualTo:@"Current Month"]
              || [groupName isEqualTo:@"Current Week"]) ) {
        [groupsController setSelectionIndex:0];
        [self applyGroupFilter];
      }
    }
  }
  
}

// ----------------------------------------------------------------------

- (void)applyGroupFilter {
  
  NSString* groupName = [[groupsController selection] valueForKey:@"name"];
  // Defaul 'nil' is removing the filer and displaying all tasks
  NSPredicate* filter = nil;

  if ([groupName isEqualTo:@"All"]) {
    
    //previousRowCount = 2;
    [predicateEditor setObjectValue:nil];
    [predicateEditor addRow:self];
    [self resizePredicateEditor];
    
    [self showView:taskView];
    
  } else if ([groupName isEqualTo:@"Current Month"]) {
    
    NSDate* firstOfThisMonth = [self dateWithFirstOfMonthFor:[NSDate date]];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* oneMonth = [[[NSDateComponents alloc] init] autorelease];
    [oneMonth setMonth:1];
    NSDate* firstOfNextMonth = [cal dateByAddingComponents:oneMonth 
                                                    toDate:firstOfThisMonth 
                                                   options:0];
    NSPredicate* p1 = [NSPredicate 
                        predicateWithFormat:@"startDate => %@", firstOfThisMonth];
    NSPredicate* p2 = [NSPredicate 
                       predicateWithFormat:@"startDate < %@", firstOfNextMonth];
    filter = [NSCompoundPredicate andPredicateWithSubpredicates:
              [NSArray arrayWithObjects:p1, p2, nil]];
    
    //previousRowCount = 3;
    [predicateEditor setObjectValue:filter];
    [self resizePredicateEditor];

    [self showView:taskView];
    
  } else if ([groupName isEqualTo:@"Current Week"]) {
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    [cal setFirstWeekday:2]; // Monday
    unsigned unitFlags = NSYearCalendarUnit | NSWeekCalendarUnit;
    NSDate* now = [NSDate date];
    NSDateComponents* comps = [cal components:unitFlags fromDate:now];
    NSDate* startOfThisWeek = [cal dateFromComponents:comps];
    NSDateComponents* oneWeek = [[[NSDateComponents alloc] init] autorelease];
    [oneWeek setWeek:1];
    NSDate* startOfNextWeek = [cal dateByAddingComponents:oneWeek
                                                   toDate:startOfThisWeek
                                                  options:0];
    filter = [NSPredicate 
              predicateWithFormat:@"startDate >= %@ and startDate < %@",
              startOfThisWeek, startOfNextWeek];

    //previousRowCount = 3;
    [predicateEditor setObjectValue:filter];
    [self resizePredicateEditor];

    [self showView:taskView];
    
  } else if ([groupName isEqualTo:@"Last Month"]) {
    
    NSDate* firstOfThisMonth = [self dateWithFirstOfMonthFor:[NSDate date]];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* 
    minusOneMonth = [[[NSDateComponents alloc] init] autorelease];
    [minusOneMonth setMonth:-1];
    NSDate* firstOfLastMonth = [cal dateByAddingComponents:minusOneMonth 
                                                    toDate:firstOfThisMonth 
                                                   options:0];
    filter = [NSPredicate 
              predicateWithFormat:@"startDate >= %@ and startDate < %@",
              firstOfLastMonth, firstOfThisMonth];

    //previousRowCount = 3;
    [predicateEditor setObjectValue:filter];
    [self resizePredicateEditor];

    [self showView:taskView];
  
  } else if ([groupName isEqualTo:@"Customers"]) {
    [self showView:customerView];
  } else if ([groupName isEqualTo:@"Projects"]) {
    [self showView:projectView];
  }
  [tasksController setFilterPredicate:filter];
}

// ----------------------------------------------------------------------

- (void)showView:(NSView*)aView {
  NSArray* allViews = [NSArray arrayWithObjects:taskView, customerView, projectView, nil];
  
  [contentViewPlaceholder addSubview:aView];
  [aView setFrameSize:[contentViewPlaceholder frame].size];

  for (NSView* view in allViews) {
    if ( view != aView ) {
      [view removeFromSuperview];
    }
  }
}


// ----------------------------------------------------------------------

#pragma mark export

// ----------------------------------------------------------------------


- (void)export:(id)sender {
  NSString *documentsDirectory = nil;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
  if ([paths count] > 0) {
    documentsDirectory = [paths objectAtIndex:0];
  }
  
  savePanel = [NSSavePanel savePanel];
  [savePanel setRequiredFileType:[fileTypeSelector titleOfSelectedItem]];
  [savePanel setCanSelectHiddenExtension:YES];
  [savePanel setAccessoryView:stdExportPanelAccessory];
  
  NSString* currentDoc = [[self fileURL] path];
  NSString* newDoc = [[[currentDoc lastPathComponent] 
                      stringByDeletingPathExtension]
                      stringByAppendingPathExtension:@"txt"];
  
  [savePanel beginSheetForDirectory:nil
                               file:newDoc
                     modalForWindow:mainWindow
                      modalDelegate:self
                     didEndSelector:@selector(exportPanelDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

// ----------------------------------------------------------------------

- (void)exportPanelDidEnd:(NSSavePanel *)sheet
             returnCode:(int)returnCode
            contextInfo:(void*)contextInfo {
  if ( returnCode == NSOKButton ) {
    BOOL fillDays = [fillDaysSelector state] == NSOnState;
    if ([[fileTypeSelector titleOfSelectedItem] isEqual:@"txt"]) {
      [self exportToText:[sheet filename] fillDays:fillDays];
    } else if ([[fileTypeSelector titleOfSelectedItem] isEqual:@"xml"]) {
      [self exportToXML:[sheet filename] fillDays:fillDays];
    }
  }
}

// ----------------------------------------------------------------------

- (void)exportToText:(NSString*)filename fillDays:(BOOL)fillDays {
  // prepare the formatter
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"y-MM-dd HH:mm"];
  
  // sort ascending by start date
  NSArray* tasks = [tasksController arrangedObjects];
  NSSortDescriptor* 
  sortDesc = [[NSSortDescriptor alloc] initWithKey:@"startDate"
                                         ascending:YES];
  tasks = [tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
  
  NSMutableString* output = [NSMutableString string];
  NSDate* lastDate = nil;
  
  for (Task* t in tasks) {
    if ( fillDays && lastDate != nil ) {
      NSDateComponents* dateDiff = [[NSCalendar currentCalendar]
                                    components:NSDayCalendarUnit
                                    fromDate:lastDate
                                    toDate:[self dmyForDate:[t startDate]]
                                    options:0];
      int i;
      for (i=1; i < [dateDiff day]; ++i) {
        NSDateComponents* days = [[NSDateComponents alloc] init];
        [days setDay:i];
        NSDate* fillDate = [[NSCalendar currentCalendar]
                            dateByAddingComponents:days
                            toDate:lastDate 
                            options:0];
        NSArray* parts = [NSArray arrayWithObjects:
                          [formatter stringFromDate:fillDate],
                          [formatter stringFromDate:fillDate],
                          0, // length
                          @"", // project
                          @"", // desc
                          nil ];
        [output appendString:[parts componentsJoinedByString:@"\t"]];
        [output appendString:@"\n"];
      }
    }
    lastDate = [self dmyForDate:[t startDate]];

    NSArray* parts = [NSArray arrayWithObjects:
                      [formatter stringFromDate:[t startDate]],
                      [formatter stringFromDate:[t endDate]],
                      [t length],
                      [[t project] valueForKey:@"name"],
                      [t desc],
                      nil ];
    [output appendString:[parts componentsJoinedByString:@"\t"]];
    [output appendString:@"\n"];
  }
  NSError* error;
  [output writeToFile:filename
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:&error];
}


// ----------------------------------------------------------------------


- (NSString *)xmlForTasks:(NSArray*)tasks fillDays:(BOOL)fillDays {
  // prepare the formatter
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"y-MM-dd HH:mm"];
  
  // sort ascending by start date
  NSSortDescriptor* 
  sortDesc = [[NSSortDescriptor alloc] initWithKey:@"startDate"
                                         ascending:YES];
  NSArray *sortedTasks 
  = [tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
  
  NSMutableString* xml = [NSMutableString string];
  [xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
  [xml appendString:@"<tasks>\n"];
  
  NSDate* lastDate = nil;
  
  for (Task* t in sortedTasks) {
    if ( fillDays && lastDate != nil ) {
      NSDateComponents* dateDiff = [[NSCalendar currentCalendar]
                                    components:NSDayCalendarUnit
                                    fromDate:lastDate
                                    toDate:[self dmyForDate:[t startDate]]
                                    options:0];
      int i;
      for (i=1; i < [dateDiff day]; ++i) {
        NSDateComponents* days = [[NSDateComponents alloc] init];
        [days setDay:i];
        NSDate* fillDate = [[NSCalendar currentCalendar]
                            dateByAddingComponents:days
                            toDate:lastDate 
                            options:0];
        [xml appendString:@"\t<task>\n"];
        [xml appendFormat:@"\t\t<start>%@</start>\n", 
         [formatter stringFromDate:fillDate]];
        [xml appendFormat:@"\t\t<end>%@</end>\n", 
         [formatter stringFromDate:fillDate]];
        [xml appendString:@"\t\t<length></length>\n"];
        [xml appendString:@"\t\t<project></project>\n"];
        [xml appendString:@"\t\t<description></description>\n"];
        [xml appendString:@"\t</task>\n"];
      }
    }
    lastDate = [self dmyForDate:[t startDate]];
    
    [xml appendString:@"\t<task>\n"];
    
    [xml appendFormat:@"\t\t<start>%@</start>\n", 
     [formatter stringFromDate:[t startDate]]];
    
    [xml appendFormat:@"\t\t<end>%@</end>\n", 
     [formatter stringFromDate:[t endDate]]];
    
    [xml appendFormat:@"\t\t<length>%@</length>\n", [t length]];
    
    [xml appendFormat:@"\t\t<project>%@</project>\n", 
     [[t project] valueForKey:@"name"]];
    
    NSManagedObject *customer = [[t project] valueForKey:@"customer"];
    [xml appendFormat:@"\t\t<customer>%@</customer>\n", 
     [customer valueForKey:@"name"]];

    [xml appendFormat:@"\t\t<description>%@</description>\n", [t desc]];
    
    [xml appendString:@"\t</task>\n"];
  }
  [xml appendString:@"</tasks>\n"];
  return xml;
}


// ----------------------------------------------------------------------

- (void)exportToXML:(NSString*)filename fillDays:(BOOL)fillDays {
  NSString *xml = [self xmlForTasks:[tasksController arrangedObjects]
                           fillDays:fillDays];

  NSError* error;
  [xml writeToFile:filename
        atomically:YES
          encoding:NSUTF8StringEncoding
             error:&error];
}


// ----------------------------------------------------------------------


- (void)fileTypeSelection:(id)sender {
  [savePanel setRequiredFileType:[fileTypeSelector titleOfSelectedItem]];
}


// ----------------------------------------------------------------------

#pragma mark xslt export

// ----------------------------------------------------------------------


- (void)processWithXslt:(id)sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setRequiredFileType:@"xsl"];
  [panel setCanChooseFiles:YES];
  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  [panel setMessage:NSLocalizedString(@"Choose XSL file for processing",
                                      @"xslt processing panel title")];
  [panel setPrompt:NSLocalizedString(@"Choose",
                                     @"xslt processing panel prompt button text")];
  [panel beginSheetForDirectory:nil 
                           file:nil 
                          types:[NSArray arrayWithObjects:@"xsl", @"xslt", nil]
                 modalForWindow:mainWindow 
                  modalDelegate:self
                 didEndSelector:@selector(xsltOpenPanelDidEnd:returnCode:contextInfo:)
                    contextInfo:nil];
}


// ----------------------------------------------------------------------


- (void)xsltOpenPanelDidEnd:(NSOpenPanel *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void*)contextInfo {
  if ( returnCode == NSOKButton ) {
    [sheet orderOut:self];
    
    NSString* currentDoc = [[self fileURL] path];
    NSString* newDoc = [[[currentDoc lastPathComponent] 
                         stringByDeletingPathExtension]
                        stringByAppendingPathExtension:@"txt"];
    NSString *xslFilename = [sheet filename];

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setCanSelectHiddenExtension:YES];
    [panel beginSheetForDirectory:nil
                             file:newDoc
                   modalForWindow:mainWindow
                    modalDelegate:self
                   didEndSelector:@selector(xsltSavePanelDidEnd:returnCode:contextInfo:)
                      contextInfo:xslFilename];
  }
}


// ----------------------------------------------------------------------


- (void)xsltSavePanelDidEnd:(NSOpenPanel *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void*)contextInfo {
  if ( returnCode == NSOKButton ) {
    NSString *xml = [self xmlForTasks:[tasksController arrangedObjects]
                             fillDays:NO];
    
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:xml 
                                                           options:0 
                                                             error:NULL] 
                          autorelease];
    NSString *xslFilename = (NSString *)contextInfo;
    NSData *xslt = [NSData dataWithContentsOfFile:xslFilename];
    id newDoc = [doc objectByApplyingXSLT:xslt arguments:nil error:NULL];
    
    NSString *output = [[[NSString alloc] initWithData:newDoc 
                                              encoding:NSUTF8StringEncoding] 
                        autorelease];
    [output writeToFile:[sheet filename]
             atomically:YES 
               encoding:NSUTF8StringEncoding
                  error:NULL];
  }
}

// ----------------------------------------------------------------------

#pragma mark predicate editor

// ----------------------------------------------------------------------


- (IBAction)predicateEditorChanged:(id)sender {
  NSPredicate* predicate = [predicateEditor predicate];
  [tasksController setFilterPredicate:predicate];

  if ([predicateEditor numberOfRows] == 0) [predicateEditor addRow:self];
  
  [self resizePredicateEditor];
}

// ----------------------------------------------------------------------

- (void)resizePredicateEditor {
  NSInteger newRowCount = [predicateEditor numberOfRows];
  
  if (newRowCount == previousRowCount) return;
  
  /* The autoresizing masks, by default, allows the outline view to grow and keeps the predicate editor fixed.  We need to temporarily grow the predicate editor, and keep the outline view fixed, so we have to change the autoresizing masks.  Save off the old ones; we'll restore them after changing the window frame. */
  NSUInteger oldDetailViewMask = [taskDetailView autoresizingMask];
  
  NSScrollView *predicateEditorScrollView = [predicateEditor enclosingScrollView];
  NSUInteger oldPredicateEditorViewMask = [predicateEditorScrollView autoresizingMask];
  
  [taskDetailView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
  [predicateEditorScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  
  BOOL growing = (newRowCount > previousRowCount);
  
  CGFloat heightDifference = fabs([predicateEditor rowHeight] * (newRowCount - previousRowCount));
  
  /* Convert the size to window coordinates.  This is very important!  If we didn't do this, we would break under scale factors other than 1.  We don't care about the horizontal dimension, so leave that as 0. */
  NSSize sizeChange = [predicateEditor convertSize:NSMakeSize(0, heightDifference) toView:nil];
  
  /* Change the window frame size.  If we're growing, the height goes up and the origin goes down (corresponding to growing down).  If we're shrinking, the height goes down and the origin goes up. */
  NSRect windowFrame = [mainWindow frame];
  windowFrame.size.height += growing ? sizeChange.height : -sizeChange.height;
  windowFrame.origin.y -= growing ? sizeChange.height : -sizeChange.height;
  [mainWindow setFrame:windowFrame display:YES animate:YES];
  
  /* restore the autoresizing mask */
  [taskDetailView setAutoresizingMask:oldDetailViewMask];
  [predicateEditorScrollView setAutoresizingMask:oldPredicateEditorViewMask];
  
  /* record our new row count */
  previousRowCount = newRowCount;
}


// ----------------------------------------------------------------------

#pragma mark text editing notifications

// ----------------------------------------------------------------------


- (void)textDidEndEditing:(NSNotification *)aNotification {
  // don't need to check for -1 index, because the notification always 
  // comes from the table view
  NSTableColumn *editedColumn = [contentList.tableColumns 
                                 objectAtIndex:contentList.editedColumn];
  
  // If we're editing the 'date' column, fix the overwritten year, hour,
  // and minute fields by restoring them from the cache. Not really pretty
  // but the best I could come up with for now.
  if ([editedColumn.identifier isEqualToString:@"date"]) {
    Task *task = [tasksController.arrangedObjects 
                  objectAtIndex:contentList.editedRow];
    NSDateComponents *editedComponents = [[NSCalendar currentCalendar]
                                          components:(NSYearCalendarUnit | 
                                                      NSMonthCalendarUnit |
                                                      NSDayCalendarUnit |
                                                      NSHourCalendarUnit |
                                                      NSMinuteCalendarUnit |
                                                      NSSecondCalendarUnit)
                                          fromDate:task.startDate];
    if (editedComponents.year == 1970 
        && cachedStartDate != nil && cachedEndDate != nil) {
      { // fix start date
        NSDateComponents *fixedComponents = [[NSCalendar currentCalendar]
                                             components:(NSYearCalendarUnit | 
                                                         NSHourCalendarUnit |
                                                       NSMinuteCalendarUnit |
                                                         NSSecondCalendarUnit)
                                             fromDate:cachedStartDate];
        [fixedComponents setMonth:editedComponents.month];
        [fixedComponents setDay:editedComponents.day];
        task.startDate = [[NSCalendar currentCalendar]
                          dateFromComponents:fixedComponents];
      }
      { // fix end date
        NSDateComponents *fixedComponents = [[NSCalendar currentCalendar]
                                             components:(NSYearCalendarUnit | 
                                                         NSHourCalendarUnit |
                                                         NSMinuteCalendarUnit |
                                                         NSSecondCalendarUnit)
                                             fromDate:cachedEndDate];
        [fixedComponents setMonth:editedComponents.month];
        [fixedComponents setDay:editedComponents.day];
        task.endDate = [[NSCalendar currentCalendar]
                        dateFromComponents:fixedComponents];
      }
    }
  }
}


// ----------------------------------------------------------------------


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
  // We're caching the previous values of the edited tasks start and end date.
  // The reason for this is that edit operations in the date colum will wipe
  // out the year, hour, and minute fields of those dates. They are restored
  // from the cache in 'textDidEndEditing:'.
  
  NSInteger rowIndex = contentList.editedRow;
  if (rowIndex >= 0) {
    Task *task = [tasksController.arrangedObjects 
                  objectAtIndex:contentList.editedRow];
    cachedStartDate = task.startDate;
    cachedEndDate = task.endDate;
  } else {
    cachedStartDate = nil;
    cachedEndDate = nil;
  }
  return YES;
}


// ----------------------------------------------------------------------



@end
