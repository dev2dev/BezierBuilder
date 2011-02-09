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
	BOOL isShiftDown = ([event modifierFlags] & NSShiftKeyMask) > 0;
	BezierPoint *point = [bezierPoints objectAtIndex:editingPoint.x];
	
	NSPoint mainTo2Diff = NSPointSubtractPoint([point mainPoint], [point controlPoint2]);
	
	if (editingPoint.y <= 0) {
		[point setMainPoint:p];
		if (editingPoint.y < 0) {
			// If we're dragging around a new current point, update all the control points
			if (editingPoint.x > 0 && editingPoint.x == [bezierPoints count] - 1) {
				BezierPoint *lastPoint = [bezierPoints objectAtIndex:editingPoint.x - 1];
				CGPoint lastMain = [lastPoint mainPoint];
				CGPoint currMain = [point mainPoint];
				
				p = NSMakePoint(lastMain.x * 0.7 + currMain.x * (1 - 0.7),
								lastMain.y * 0.7 + currMain.y * (1 - 0.7));
				[point setControlPoint1:p];
				
				p = NSMakePoint(lastMain.x * 0.3 + currMain.x * (1 - 0.3),
								lastMain.y * 0.3 + currMain.y * (1 - 0.3));
				[point setControlPoint2:p];
			}
		}
		else if (isShiftDown) {
			p.x = [point mainPoint].x - mainTo2Diff.x;
			p.y = [point mainPoint].y - mainTo2Diff.y;
			[point setControlPoint2:p];
		}
	} else if (editingPoint.y == 1) {
		[point setControlPoint1:p];
		// The only point that it would make sense to change is the previous
		// main point. But if you're going to do that, you'd also want to modify
		// the previous point's control2 as well.
	} else if (editingPoint.y == 2) {
		[point setControlPoint2:p];
		if (isShiftDown) {
			p.x = [point controlPoint2].x + mainTo2Diff.x;
			p.y = [point controlPoint2].y + mainTo2Diff.y;
			[point setMainPoint:p];
		}
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	editingPoint = [self locationOfPathElementNearPoint:local_point];
	
	if (editingPoint.x < 0) {
		CGPoint control1 = local_point;
		CGPoint control2 = local_point;
		
		BezierPoint *lastPoint = [bezierPoints lastObject];
		if (lastPoint) {
			NSPoint lastMain = [lastPoint mainPoint];

			control1 = NSMakePoint(lastMain.x * 0.7 + local_point.x * (1 - 0.7),
								   lastMain.y * 0.7 + local_point.y * (1 - 0.7));

			control2 = NSMakePoint(lastMain.x * 0.3 + local_point.x * (1 - 0.3),
								   lastMain.y * 0.3 + local_point.y * (1 - 0.3));
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
	[[NSColor blackColor] set];
	NSBezierPath * path = [NSBezierPathCodeBuilder objectForBezierPoints:bezierPoints];
	[path stroke];
	
	[[NSColor redColor] set];
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
}

- (void) dealloc {
	[bezierPoints release];
	[super dealloc];
}

@end
