//
//  MyDocument.m
//  PdbX
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"

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
    // user interface preparation code
}

@end
