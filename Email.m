//
//  Email.m
//  MailDemo
//
//  Created by Scott Stevenson on Wed Apr 21 2004.
//  Copyright (c) 2004 Tree House Ideas. All rights reserved.
//


#import "Email.h"


@implementation Email




- (id)init
{
    if (self = [super init]) {
        NSArray *keys = [NSArray arrayWithObjects:@"address", @"subject", @"date", @"body", nil];
        NSArray *values = [NSArray arrayWithObjects:@"test@test.com", @"Subject", [NSDate date], @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", nil];
        properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
    }
    return self;
}




- (void)dealloc
{
    [properties release];
    [super dealloc];
}




- (NSMutableDictionary *)properties
{
    return properties;
}




- (void)setProperties:(NSDictionary *)newProperties
{
    if (properties != newProperties) {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary:newProperties];
    }
}




- (NSString *)subject
{
	return [properties valueForKey:@"subject"];
}




- (void)setSubject:(NSString *)newSubject
{
	[properties setValue:newSubject
				  forKey:@"subject"];
}





@end
