//
//  AppController.m
//  Hourglass
//
//  Created by Sven A. Schmidt on 31.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"


@implementation AppController

// ----------------------------------------------------------------------

- (BOOL) applicationShouldOpenUntitledFile:(NSApplication*)app {
  return YES;
}

// ----------------------------------------------------------------------
      
- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender {
  NSDocumentController* docController = [NSDocumentController sharedDocumentController];
  NSArray* recentDocs = [docController recentDocumentURLs];
  if ([recentDocs count] > 0) {
    NSError* error;
    id doc = [docController 
              openDocumentWithContentsOfURL:[recentDocs objectAtIndex:0] 
              display:YES
              error:&error];
    return (doc != nil);
  } else {
    NSError* error;
    id doc = [docController openUntitledDocumentAndDisplay:YES error:&error];
    return (doc != nil);
  }
}

// ----------------------------------------------------------------------

@end
