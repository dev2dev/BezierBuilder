//
//  NSBezierPathCodeBuilder.m
//  BezierBuilder
//
//  Created by Dave DeLong on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSBezierPathCodeBuilder.h"
#import "BezierPoint.h"

@implementation NSBezierPathCodeBuilder

+ (NSString *) codeForBezierPoints:(NSArray *)points {
	NSMutableArray *lines = [NSMutableArray array];
	
	[lines addObject:@"NSBezierPath *bp = [[NSBezierPath alloc] init];"];
	for (NSUInteger i = 0; i < [points count]; ++i) {
		BezierPoint *point = [points objectAtIndex:i];
		if (i == 0) {
			[lines addObject:[NSString stringWithFormat:@"[bp moveToPoint:NSMakePoint(%f, %f)]", [point mainPoint].x, [point mainPoint].y]];
		} else {
			[lines addObject:[NSString stringWithFormat:@"[bp curveToPoint:NSMakePoint(%f, %f) controlPoint1:NSMakePoint(%f, %f) controlPoint2:NSMakePoint(%f, %f)];", 
							  [point mainPoint].x, [point mainPoint].y,
							  [point controlPoint1].x, [point controlPoint1].y,
							  [point controlPoint2].x, [point controlPoint2].y]];
		}
	}
	
	[lines addObject:@"[bp stroke];"];
	[lines addObject:@"[bp release];"];
	
	return [lines componentsJoinedByString:@"\n"];
}

+ (id) objectForBezierPoints:(NSArray *)points {
	NSBezierPath *bp = [[NSBezierPath alloc] init];
	for (NSUInteger i = 0; i < [points count]; ++i) {
		BezierPoint *point = [points objectAtIndex:i];
		if (i == 0) {
			[bp moveToPoint:NSMakePoint([point mainPoint].x, [point mainPoint].y)];
		} else {
			[bp curveToPoint:NSMakePoint([point mainPoint].x, [point mainPoint].y) 
			   controlPoint1:NSMakePoint([point controlPoint1].x, [point controlPoint1].y) 
			   controlPoint2:NSMakePoint([point controlPoint2].x, [point controlPoint2].y)];
		}
	}
	
	return [bp autorelease];
}

@end
