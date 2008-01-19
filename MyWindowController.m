//
//  MyWindowController.m
//
//  Created by Dave Batton, August 2006.
//  http://www.Mere-Mortal-Software.com/
//
//  Copyright 2006 by Dave Batton. Some rights reserved.
//  http://creativecommons.org/licenses/by/2.5/
//

#import "MyWindowController.h"

@implementation MyWindowController

- (void)awakeFromNib {
  // Place the source list view in the left panel.
	[sourceView setFrameSize:[sourceViewPlaceholder frame].size];
	[sourceViewPlaceholder addSubview:sourceView];
  
  // Place the content view in the right panel.
	[contentView setFrameSize:[contentViewPlaceholder frame].size];
	[contentViewPlaceholder addSubview:contentView];
}


@end
