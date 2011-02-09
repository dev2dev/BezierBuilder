//
//  BezierView.m
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BezierView.h"
#import "BezierPoint.h"
#import "NSBezierPathCodeBuilder.h"

float NSDistanceFromPointToPoint(NSPoint point1, NSPoint point2) {
	float dx2 = (point1.x - point2.x) * (point1.x - point2.x);
	float dy2 = (point1.y - point2.y) * (point1.y - point2.y);
	return sqrt(dx2 + dy2);
}


@implementation BezierView

@synthesize delegate, bezierPoints;

- (void) awakeFromNib {
	bezierPoints = [[NSMutableArray alloc] init];
	editingPoint = NSMakePoint(-1, -1);
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

#define NEAR_THRESHOLD 15

- (NSPoint) locationOfPathElementNearPoint:(NSPoint)aPoint {
	NSPoint closest = NSMakePoint(-1, -1);
	
	float distance = FLT_MAX;
	for (NSUInteger i = 0; i < [bezierPoints count]; ++i) {
		BezierPoint *p = [bezierPoints objectAtIndex:i];
		float tDistance = 0;
		if (i > 0) {
			tDistance = NSDistanceFromPointToPoint(aPoint, [p controlPoint2]);
			if (tDistance <= distance && tDistance <= NEAR_THRESHOLD) {
				distance = tDistance;
				closest = NSMakePoint(i, 2);
			}
			tDistance = NSDistanceFromPointToPoint(aPoint, [p controlPoint1]);
			if (tDistance <= distance && tDistance <= NEAR_THRESHOLD) {
				distance = tDistance;
				closest = NSMakePoint(i, 1);
			}
		}
		tDistance = NSDistanceFromPointToPoint(aPoint, [p mainPoint]);
		if (tDistance <= distance && tDistance <= NEAR_THRESHOLD) {
			distance = tDistance;
			closest = NSMakePoint(i, 0);
		}
	}
	return closest;
}

#define CONTROL_OFFSET 20

- (void) updateEditingPointWithPoint:(NSPoint)p withEvent:(NSEvent *)event {
	BezierPoint *point = [bezierPoints objectAtIndex:editingPoint.x];
	
	if (editingPoint.y <= 0) {
		NSPoint diff = NSPointSubtractPoint(p, [point mainPoint]);
		[point setMainPoint:p];

		NSPoint newPoint = NSPointAddToPoint(diff, [point controlPoint2]);
		[point setControlPoint2:newPoint];
		
		if (editingPoint.x < [bezierPoints count] - 1) {
			// Update c1 of the next point too
			BezierPoint *nextPoint = [bezierPoints objectAtIndex:editingPoint.x + 1];
			newPoint = NSPointAddToPoint(diff, [nextPoint controlPoint1]);
			[nextPoint setControlPoint1:newPoint];
		}
	} else if (editingPoint.y == 1) {
		[point setControlPoint1:p];
	} else if (editingPoint.y == 2) {
		[point setControlPoint2:p];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	editingPoint = [self locationOfPathElementNearPoint:local_point];
	
	if (editingPoint.x < 0) {
		// It's a new point
		CGPoint control1 = local_point;
		CGPoint control2 = local_point;
		
		NSUInteger pointCount = [bezierPoints count];
		
		BezierPoint *lastPoint = [bezierPoints lastObject];
		if (pointCount == 1) {
			// This is the first curve segment, so extrapolating from the
			// trajectory of the previous segment makes no sense
			NSPoint prevMain = [lastPoint mainPoint];
			
			control1 = NSMakePoint(prevMain.x * 0.7 + local_point.x * (1 - 0.7),
								   prevMain.y * 0.7 + local_point.y * (1 - 0.7));
			
			control2 = NSMakePoint(prevMain.x * 0.3 + local_point.x * (1 - 0.3),
								   prevMain.y * 0.3 + local_point.y * (1 - 0.3));
		}
		else if (pointCount > 1) {
			NSPoint prevC2 = [lastPoint controlPoint2];
			NSPoint prevMain = [lastPoint mainPoint];
			
			NSPoint trajectory = NSPointSubtractPoint(prevMain, prevC2);
			control1 = NSPointAddToPoint(prevMain, trajectory);
			
			control2 = NSMakePoint(control1.x * 0.5 + local_point.x * (1 - 0.5),
								   control1.y * 0.5 + local_point.y * (1 - 0.5));
		}
		
		BezierPoint *newPoint = [[BezierPoint alloc] init];
		[newPoint setMainPoint:local_point];
		[newPoint setControlPoint1:control1];
		[newPoint setControlPoint2:control2];
		[bezierPoints addObject:newPoint];
		[newPoint release];
		
		[[self delegate] elementsDidChangeInBezierView:self];
		
		//setting y to -1 means that all the control points will be dragged
		editingPoint = NSMakePoint([bezierPoints count]-1, -1);
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	[self updateEditingPointWithPoint:local_point withEvent:theEvent];
	[[self delegate] elementsDidChangeInBezierView:self];
}

- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	[self updateEditingPointWithPoint:local_point withEvent:theEvent];
	[[self delegate] elementsDidChangeInBezierView:self];
}

#define HANDLE_WIDTH 5
#define HANDLE_HEIGHT 5

- (void)drawRect:(NSRect)dirtyRect {
	[[[NSColor redColor] colorWithAlphaComponent:0.7] set];
	NSBezierPath * extra = [[NSBezierPath alloc] init];
	for (NSUInteger i = 0; i < [bezierPoints count]; ++i) {
		BezierPoint *bezierPoint = [bezierPoints objectAtIndex:i];
		NSRect r;
		if (i > 0) {
			[extra moveToPoint:[[bezierPoints objectAtIndex:i-1] mainPoint]];
			[extra lineToPoint:[bezierPoint controlPoint1]];
			[extra moveToPoint:[bezierPoint controlPoint2]];
			[extra lineToPoint:[bezierPoint mainPoint]];
			
			r = NSMakeRect([bezierPoint controlPoint1].x, [bezierPoint controlPoint1].y, HANDLE_WIDTH, HANDLE_HEIGHT);
			r = NSOffsetRect(r, -HANDLE_WIDTH/2, -HANDLE_HEIGHT/2);
			[extra appendBezierPathWithOvalInRect:r];
			
			r = NSMakeRect([bezierPoint controlPoint2].x, [bezierPoint controlPoint2].y, HANDLE_WIDTH, HANDLE_HEIGHT);
			r = NSOffsetRect(r, -HANDLE_WIDTH/2, -HANDLE_HEIGHT/2);
			[extra appendBezierPathWithOvalInRect:r];
		}
		
		r = NSMakeRect([bezierPoint mainPoint].x, [bezierPoint mainPoint].y, HANDLE_WIDTH, HANDLE_HEIGHT);
		r = NSOffsetRect(r, -HANDLE_WIDTH/2, -HANDLE_HEIGHT/2);
		[extra appendBezierPathWithOvalInRect:r];
	}
	[extra stroke];
	[extra release];
	
	[[NSColor blackColor] set];
	NSBezierPath * path = [NSBezierPathCodeBuilder objectForBezierPoints:bezierPoints];
	[path stroke];
}

- (void) dealloc {
	[bezierPoints release];
	[super dealloc];
}

@end
