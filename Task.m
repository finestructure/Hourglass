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
  [self setValue:[NSDate date] forKey:@"endDate"];
  /*
  [self addObserver:self 
         forKeyPath:@"startDate" 
            options:NSKeyValueObservingOptionNew
            context:NULL];
   */
}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
  if ([keyPath isEqualTo:@"startDate"]) {
    NSLog(@"observing: %@", keyPath);
    [super setValue:[self valueForKey:@"startDate"] forKey:@"startTime"];
  }
}
*/


- (NSDate*)dateWithDate:(NSDate*)date andTime:(NSDate*)time {
  NSCalendar* cal = [NSCalendar currentCalendar];
  unsigned dateFlags = ( NSYearCalendarUnit 
                        | NSMonthCalendarUnit 
                        | NSDayCalendarUnit );
  NSDateComponents* dateComponents = [cal components:dateFlags
                                            fromDate:date];
  unsigned timeFlags = ( NSHourCalendarUnit
                        | NSMinuteCalendarUnit
                        | NSSecondCalendarUnit );
  NSDateComponents* timeComponents = [cal components:timeFlags 
                                            fromDate:time];
  [dateComponents setHour:[timeComponents hour]];
  [dateComponents setMinute:[timeComponents minute]];
  [dateComponents setSecond:[timeComponents second]];
  return [cal dateFromComponents:dateComponents];
}


- (void)setStartTime:(NSDate*)time {
  NSCalendarDate* currentDate = [self valueForKey:@"startDate"];
  [self setValue:[self dateWithDate:currentDate andTime:time]
          forKey:@"startDate"];
}


- (NSDate*)startTime {
  return [self valueForKey:@"startDate"];
}


- (void)setEndTime:(NSDate*)time {
  NSCalendarDate* currentDate = [self valueForKey:@"endDate"];
  [self setValue:[self dateWithDate:currentDate andTime:time]
          forKey:@"endDate"];
}


- (NSDate*)endTime {
  return [self valueForKey:@"endDate"];
}

/*
- (void)setStartDate:(NSDate*)date {
  [super setValue:date forKey:@"startDate"];
  //[self setPrimitiveValue:date forKey:@"startTime"];
}


- (void)setEndDate:(NSDate*)date {
  [super setValue:date forKey:@"endDate"];
  //[self setPrimitiveValue:date forKey:@"endTime"];
}
*/

@end
