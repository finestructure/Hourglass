//
//  Task.m
//  PdbX
//
//  Created by Sven A. Schmidt on 17.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Task.h"


@implementation Task

// ----------------------------------------------------------------------

+ (void)initialize {
  [self setKeys:[NSArray arrayWithObjects:@"startDate",nil]triggerChangeNotificationsForDependentKey:@"startTime"];
  [self setKeys:[NSArray arrayWithObjects:@"endDate",nil]triggerChangeNotificationsForDependentKey:@"endTime"];
}

// ----------------------------------------------------------------------

- (void)awakeFromInsert {
  [self setValue:[NSDate date] forKey:@"startDate"];
  [self setValue:[NSDate date] forKey:@"endDate"];
}

// ----------------------------------------------------------------------

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

// ----------------------------------------------------------------------

- (void)setStartTime:(NSDate*)time {
  NSCalendarDate* currentDate = [self valueForKey:@"startDate"];
  [self setValue:[self dateWithDate:currentDate andTime:time]
          forKey:@"startDate"];
}

// ----------------------------------------------------------------------

- (NSDate*)startTime {
  return [self valueForKey:@"startDate"];
}

// ----------------------------------------------------------------------

- (void)setEndTime:(NSDate*)time {
  NSCalendarDate* currentDate = [self valueForKey:@"endDate"];
  [self setValue:[self dateWithDate:currentDate andTime:time]
          forKey:@"endDate"];
}

// ----------------------------------------------------------------------

- (NSDate*)endTime {
  return [self valueForKey:@"endDate"];
}

// ----------------------------------------------------------------------

@end
