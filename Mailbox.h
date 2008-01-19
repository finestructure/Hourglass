//
//  Mailbox.h
//  MailDemo
//
//  Created by Scott Stevenson on Wed Apr 21 2004.
//  Copyright (c) 2004 Tree House Ideas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Mailbox : NSObject {
	
    NSMutableDictionary *properties;
    NSMutableArray *emails;
}

- (NSMutableDictionary *)properties;
- (void)setProperties:(NSDictionary *)newProperties;

- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

- (NSMutableArray *)emails;
- (void)setEmails:(NSArray *) newEmails;

@end
