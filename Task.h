//
//  Task.h
//  PdbX
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Task : NSManagedObject {

}

- (NSDate*)dateWithDate:(NSDate*)date andTime:(NSDate*)time;


@property(readonly) NSDate* startDate;
@property(readonly) NSDate* endDate;
@property(readonly) NSString* desc;
@property(readonly) NSNumber* length;
@property(readonly) id project;


@end
