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

+ (NSString *) codeForBezierPoints:(NSArray *)points {
	NSMutableArray *lines = [NSMutableArray array];
	
	[lines addObject:@"CGMutablePathRef path = CGPathCreateMutable();"];
	for (NSUInteger i = 0; i < [points count]; ++i) {
		BezierPoint *point = [points objectAtIndex:i];
		if (i == 0) {
			[lines addObject:[NSString stringWithFormat:@"CGPathMoveToPoint(path, NULL, %f, %f);", [point mainPoint].x, [point mainPoint].y]];
		} else {
			[lines addObject:[NSString stringWithFormat:@"CGPathAddCurveToPoint(path, NULL, %f, %f, %f, %f, %f, %f);",
							  [point controlPoint1].x, [point controlPoint1].y,
							  [point controlPoint2].x, [point controlPoint2].y,
							  [point mainPoint].x, [point mainPoint].y]];
		}
	}
	
	[lines addObject:@"CGContextAddPath(<#CGContextRef#>, path);"];
	[lines addObject:@"CGContextStrokePath(<#CGContextRef#>);"];
	[lines addObject:@"CFRelease(path);"];
	
	return [lines componentsJoinedByString:@"\n"];
}

@end
