//
//  Group.m
//  PdbX
//
//  Created by Sven A. Schmidt on 20.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Group.h"


@implementation Group

- (void)awakeFromInsert {
  [self setValue:[[NSImage imageNamed:@"Folder"] TIFFRepresentation]
          forKey:@"icon"];
}

@end