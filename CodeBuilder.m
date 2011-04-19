//
//  CodeBuilder.m
//  BezierBuilder
//
//  Created by Dave DeLong on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeBuilder.h"
#import "BezierPoint.h"


@implementation CodeBuilder
@synthesize yOrigin, bezierPoints;

- (NSArray *)effectiveBezierPoints {
	if (yOrigin == 0.0) {
		return bezierPoints;
	}
	else {
		NSMutableArray *effectivePoints = [NSMutableArray array];
		for (BezierPoint *point in bezierPoints) {
			CGPoint mainPoint = [point mainPoint];
			CGPoint control1 = [point controlPoint1];
			CGPoint control2 = [point controlPoint2];
			
			CGPoint newMain = CGPointMake(mainPoint.x, yOrigin - mainPoint.y);
			CGPoint newC1 = CGPointMake(control1.x, yOrigin - control1.y);
			CGPoint newC2 = CGPointMake(control2.x, yOrigin - control2.y);
			
			BezierPoint *newPoint = [[BezierPoint alloc] init];
			[newPoint setMainPoint:newMain];
			[newPoint setControlPoint1:newC1];
			[newPoint setControlPoint2:newC2];
			[effectivePoints addObject:newPoint];
			[newPoint release];
		}
		return effectivePoints;
	}
}

- (NSString *) codeForBezierPoints {
	NSLog(@"SUBCLASSES MUST OVERRIDE");
	return nil;
}

- (id) objectForBezierPoints {
	NSLog(@"SUBCLASSES MUST OVERRIDE");
	return nil;
}

- (void)dealloc {
	[bezierPoints release];
	[super dealloc];
}

@end
