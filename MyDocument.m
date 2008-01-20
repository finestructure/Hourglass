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

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

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
  
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Group" inManagedObjectContext:moc];
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  
  NSError *error = nil;
  NSArray *groups = [moc executeFetchRequest:request error:&error];
  if (groups == nil) {
    NSLog(@"no groups (nil)");
    return;
  }
  
  //NSArray* groups = [groupsController arrangedObjects];
  NSLog(@"existing groups: %d", [groups count]);
  for (id g in groups) {
    NSLog(@"\tname: %@", [g name]);
  }
  NSPredicate* p = [NSPredicate predicateWithFormat:@"name like \"Current Month\""];
  NSLog(@"filtering groups");
  NSArray* g1 = [groups filteredArrayUsingPredicate:p];
  NSLog(@"g1 count: %d", [g1 count]);
  if ([g1 count] == 0) {
    NSLog(@"nothing found");
    id g = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext: [self managedObjectContext]];
    [g setValue:@"Current Month" forKey:@"name"];
    [g setValue:[[NSImage imageNamed:@"Folder"] TIFFRepresentation]
         forKey:@"icon"];
    NSLog(@"adding object");
    [groupsController addObject:g];
  }
}

- (void)newTask:(id)sender {
  [tasksController add:sender];
}

@end
