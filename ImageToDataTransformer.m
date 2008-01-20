//
//  ImageToDataTransformer.m
//  PdbX
//
//  Created by Sven A. Schmidt on 20.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ImageToDataTransformer.h"


@implementation ImageToDataTransformer

//----------------------------------------------------------------------

+ (Class)transformedValueClass
{
  return [NSImage class];
}

//----------------------------------------------------------------------

+ (BOOL)allowsReverseTransformation
{
  return YES;
}

//----------------------------------------------------------------------

- (NSImage*)transformedValue:(NSData*)value 
{  
  if (value == nil) return nil;
    
  return [[[NSImage alloc] initWithData:value] autorelease];
}

//----------------------------------------------------------------------

- (NSData*)reverseTransformedValue:(NSImage*)value
{
  if (value == nil) return nil;

  return [value TIFFRepresentation];
}

//----------------------------------------------------------------------

@end
