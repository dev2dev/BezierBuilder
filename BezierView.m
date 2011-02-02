//
//  BezierView.m
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BezierView.h"

float NSDistanceFromPointToPoint(NSPoint point1, NSPoint point2) {
	float dx2 = (point1.x - point2.x) * (point1.x - point2.x);
	float dy2 = (point1.y - point2.y) * (point1.y - point2.y);
	return sqrt(dx2 + dy2);
}

@implementation BezierView

@synthesize delegate;

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void) flagsChanged:(NSEvent *)event {
	isShiftDown = (([event modifierFlags] & NSShiftKeyMask) > 0);
}

- (NSPoint) locationOfPathElementNearPoint:(NSPoint)aPoint {
	NSBezierPath * path = [delegate path];
	NSPoint closest = NSMakePoint(-1, -1);
	
	int elemCount = [path elementCount];
	float distance = FLT_MAX;
	for (int i = 0; i < elemCount; ++i) {
		NSPoint points[3];
		NSBezierPathElement element = [path elementAtIndex:(elemCount - 1) associatedPoints:points];
		float tDistance = 0;
		switch (element) {
			case NSCurveToBezierPathElement:
				tDistance = NSDistanceFromPointToPoint(aPoint, points[2]);
				NSLog(@"tDist %d,2: %f", i, tDistance);
				if (tDistance <= distance && tDistance <= 5) {
					distance = tDistance;
					closest = NSMakePoint(i, 2);
				}
				tDistance = NSDistanceFromPointToPoint(aPoint, points[1]);
				NSLog(@"tDist %d,1: %f", i, tDistance);
				if (tDistance <= distance && tDistance <= 5) {
					distance = tDistance;
					closest = NSMakePoint(i, 1);
				}
			default:
				tDistance = NSDistanceFromPointToPoint(aPoint, points[0]);
				NSLog(@"tDist %d,0: %f", i, tDistance);
				if (tDistance <= distance && tDistance <= 5) {
					distance = tDistance;
					closest = NSMakePoint(i, 0);
				}
		}
	}
	return closest;
}

- (NSPointArray) pointArrayAtPoint:(NSPoint)centerPoint {
	NSPoint * points = malloc(3 * sizeof(NSPoint));
	points[0] = centerPoint;
	points[1] = NSMakePoint(MAX(centerPoint.x+20, 0), centerPoint.y);
	points[2] = NSMakePoint(MIN(centerPoint.x-20, [self frame].size.width), centerPoint.y);
	return points;
}

- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	editingPoint = [self locationOfPathElementNearPoint:local_point];
	previousPoint = local_point;
	if (editingPoint.y <= 0 && isShiftDown) { editingPoint.y = -1; }
	if (editingPoint.x < 0) {
		NSPoint * points = [self pointArrayAtPoint:local_point];
		[[self delegate] didAddPoints:points];
		free(points);
		//setting y to -1 means that all the control points will be dragged
		editingPoint = NSMakePoint([[[self delegate] path] elementCount]-1, -1);
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	[[self delegate] didChangeElementAtIndex:editingPoint byDelta:NSPointSubtractPoint(local_point, previousPoint)];
	previousPoint = local_point;
}

- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	[[self delegate] didChangeElementAtIndex:editingPoint byDelta:NSPointSubtractPoint(local_point, previousPoint)];
	previousPoint = local_point;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSBezierPath * path = [delegate path];
	[path stroke];
	
	[[NSColor redColor] set];
	NSBezierPath * extra = [[NSBezierPath alloc] init];
	int elemCount = [path elementCount];
	for (int i = 0; i < elemCount; ++i) {
		NSPoint points[3];
		NSBezierPathElement element = [path elementAtIndex:i associatedPoints:points];
		NSRect rect;
		switch (element) {
			case NSCurveToBezierPathElement:
				[extra moveToPoint:points[1]];
				[extra lineToPoint:points[0]];
				[extra lineToPoint:points[2]];
				rect = NSMakeRect(points[1].x-2, points[1].y-2, 5, 5);
				[extra appendBezierPathWithOvalInRect:rect];
				rect = NSMakeRect(points[2].x-2, points[2].y-2, 5, 5);
				[extra appendBezierPathWithOvalInRect:rect];
			default:
				rect = NSMakeRect(points[0].x-2, points[0].y-2, 5, 5);
				[extra appendBezierPathWithOvalInRect:rect];
		}
	}
	[extra stroke];
	[extra release];
}

@end
