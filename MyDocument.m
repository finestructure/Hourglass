//
//  MyDocument.m
//  PdbX
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"

#import "Group.h"

@implementation MyDocument

// ----------------------------------------------------------------------

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

// ----------------------------------------------------------------------

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

// ----------------------------------------------------------------------

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
  [super windowControllerDidLoadNib:windowController];

  // Place the source list view in the left panel.
	[sourceView setFrameSize:[sourceViewPlaceholder frame].size];
	[sourceViewPlaceholder addSubview:sourceView];
  
  // Place the content view in the right panel.
	[contentView setFrameSize:[contentViewPlaceholder frame].size];
	[contentViewPlaceholder addSubview:contentView];
  
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
    [self ensure:groups containsName:@"Current Month"];
    [self ensure:groups containsName:@"Current Week"];
    [self ensure:groups containsName:@"Last Month"];
    [self ensure:groups containsName:@"All"];
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey:@"sortIndex"
                                                       ascending:YES];
    [groupsController setSortDescriptors:[NSArray arrayWithObject:sd]];

    // clear the undo manager and change count for the document such that
    // untitled documents start with zero unsaved changes
    [moc processPendingChanges];
    [[moc undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
  }

  // set up selection observing
  {
    [groupsController addObserver:self 
                       forKeyPath:@"selection" 
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
  }
}

// ----------------------------------------------------------------------

- (void)ensure:(id)groups
  containsName:(NSString*)groupName {
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
    [g setValue:[[NSImage imageNamed:@"Folder"] TIFFRepresentation]
         forKey:@"icon"];
    [g setValue:[NSNumber numberWithInt:sortIndex] forKey:@"sortIndex"];
    ++sortIndex;
  }
}

// ----------------------------------------------------------------------

- (void)newTask:(id)sender {
  [tasksController add:sender];
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

- (void)showCustomerWindow:(id)sender {
  [customerWindow makeKeyAndOrderFront:sender];
}

// ----------------------------------------------------------------------

- (void)showProjectWindow:(id)sender {
  [projectWindow makeKeyAndOrderFront:sender];
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
  if ([keyPath isEqualTo:@"selection"]) {
    NSString* groupName = [[groupsController selection] valueForKey:@"name"];
    // Defaul 'nil' is removing the filer and displaying all tasks
    NSPredicate* filter = nil;
    if ([groupName isEqualTo:@"Current Month"]) {
      NSDate* firstOfThisMonth = [self dateWithFirstOfMonthFor:[NSDate date]];
      NSCalendar* cal = [NSCalendar currentCalendar];
      NSDateComponents* oneMonth = [[[NSDateComponents alloc] init] autorelease];
      [oneMonth setMonth:1];
      NSDate* firstOfNextMonth = [cal dateByAddingComponents:oneMonth 
                                                      toDate:firstOfThisMonth 
                                                     options:0];
      filter = [NSPredicate 
                predicateWithFormat:@"%@ <= startDate and startDate < %@",
                firstOfThisMonth, firstOfNextMonth];
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
                predicateWithFormat:@"%@ <= startDate and startDate < %@",
                startOfThisWeek, startOfNextWeek];
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
                predicateWithFormat:@"%@ <= startDate and startDate < %@",
                firstOfLastMonth, firstOfThisMonth];
    }
    [tasksController setFilterPredicate:filter];
  }
}

// ----------------------------------------------------------------------

@end
