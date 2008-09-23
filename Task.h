//
//  Task.h
//  Hourglass
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Task : NSManagedObject {

}

- (NSDate*)dateWithDate:(NSDate*)date andTime:(NSDate*)time;


@property(assign) NSDate* startDate;
@property(assign) NSDate* endDate;
@property(assign) NSString* desc;
@property(assign) NSNumber* length;
@property(assign) id project;


@end
