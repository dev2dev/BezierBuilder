//
//  CodeBuilder.m
//  BezierBuilder
//
//  Created by Dave DeLong on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeBuilder.h"


@implementation CodeBuilder

+ (NSString *) codeForBezierPoints:(NSArray *)points {
	NSLog(@"SUBCLASSES MUST OVERRIDE");
	return nil;
}

+ (id) objectForBezierPoints:(NSArray *)points {
	NSLog(@"SUBCLASSES MUST OVERRIDE");
	return nil;
}

@end
