//
//  Task.m
//  PdbX
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Task.h"


@implementation Task

- (void)awakeFromInsert {
  [self setValue:[NSDate date] forKey:@"startDate"];
}

@end
