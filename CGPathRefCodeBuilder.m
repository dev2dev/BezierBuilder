//
//  CGPathRefCodeBuilder.m
//  BezierBuilder
//
//  Created by Dave DeLong on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CGPathRefCodeBuilder.h"
#import "BezierPoint.h"


@implementation CGPathRefCodeBuilder

- (NSString *) codeForBezierPoints {
	NSArray *points = [self effectiveBezierPoints];
	NSMutableArray *lines = [NSMutableArray array];
	
	[lines addObject:@"CGMutablePathRef path = CGPathCreateMutable();"];
	for (NSUInteger i = 0; i < [points count]; ++i) {
		BezierPoint *point = [points objectAtIndex:i];
		if (i == 0) {
			[lines addObject:[NSString stringWithFormat:@"CGPathMoveToPoint(path, NULL, %0.2f, %0.2f);", [point mainPoint].x, [point mainPoint].y]];
		} else {
			[lines addObject:[NSString stringWithFormat:@"CGPathAddCurveToPoint(path, NULL, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f);",
							  [point controlPoint1].x, [point controlPoint1].y,
							  [point controlPoint2].x, [point controlPoint2].y,
							  [point mainPoint].x, [point mainPoint].y]];
		}
	}
	
	[lines addObject:@"CGContextAddPath(<#CGContextRef#>, path);"];
	[lines addObject:@"CGContextStrokePath(<#CGContextRef#>);"];
	[lines addObject:@"CGPathRelease(path);"];
	
	return [lines componentsJoinedByString:@"\n"];
}

@end
