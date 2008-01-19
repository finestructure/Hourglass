//
//  Mailbox.m
//  MailDemo
//
//  Created by Scott Stevenson on Wed Apr 21 2004.
//  Copyright (c) 2004 Tree House Ideas. All rights reserved.
//


#import "Mailbox.h"


@implementation Mailbox




- (id)init
{
    if (self = [super init]) {
        NSArray *keys = [NSArray arrayWithObjects:@"title", @"icon", nil];
        NSArray *values = [NSArray arrayWithObjects:@"New Mailbox", [NSImage imageNamed:@"Folder"], nil];
        properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
        
        emails = [[NSMutableArray alloc] init];
    }
    return self;
}




- (void)dealloc
{
    [properties release];
    [emails release];
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




- (NSString *)title
{
	return [properties valueForKey:@"title"];
}




- (void)setTitle:(NSString *)newTitle
{
	[properties setValue:newTitle
				  forKey:@"title"];
}





- (NSMutableArray *)emails
{
    return emails;
}




- (void) setEmails:(NSArray *)newEmails
{
    if (emails != newEmails) {
        [emails autorelease];
        emails = [[NSMutableArray alloc] initWithArray:newEmails];
    }
}




@end
