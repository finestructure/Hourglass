//
//  DefaultGroup.h
//  PdbX
//
//  Created by Sven A. Schmidt on 22.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DefaultGroup : NSObject {

  NSString* name;
  NSData* icon;
  
}

@property(assign) NSString* name;
@property(assign) NSData* icon;

@end
