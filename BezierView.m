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

NSPoint NSInterpolatePoints(NSPoint point1, NSPoint point2, float amount) {
	return NSMakePoint(point1.x * (1-amount) + point2.x * amount,
					   point1.y * (1-amount) + point2.y * amount);
}

NSPoint NSNormalizedPoint(NSPoint point) {
	float magnitude = sqrtf(point.x * point.x + point.y * point.y);
	return NSMakePoint(point.x / magnitude, point.y / magnitude);
}

NSPoint NSScaledPoint(NSPoint point, float scale) {
	return NSMakePoint(point.x * scale, point.y * scale);
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

#define NEAR_THRESHOLD 10

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
	BOOL isCommandDown = ([event modifierFlags] & NSCommandKeyMask) > 0;
	BezierPoint *point = [bezierPoints objectAtIndex:editingPoint.x];
	
	if (editingPoint.y == -1) {
		[point setMainPoint:p];
		NSPoint c1 = [point controlPoint1];
		
		NSPoint newC2 = NSInterpolatePoints(c1, p, 0.5);
		[point setControlPoint2:newC2];
	}
	else if (editingPoint.y == 0) {
		NSPoint diff = NSPointSubtractPoint(p, [point mainPoint]);
		[point setMainPoint:p];
		
		if (!isCommandDown) {
			NSPoint newPoint = NSPointAddToPoint(diff, [point controlPoint2]);
			[point setControlPoint2:newPoint];
		}
		
		if (!isCommandDown && editingPoint.x < [bezierPoints count] - 1) {
			// Update c1 of the next point too
			BezierPoint *nextPoint = [bezierPoints objectAtIndex:editingPoint.x + 1];
			NSPoint newPoint = NSPointAddToPoint(diff, [nextPoint controlPoint1]);
			[nextPoint setControlPoint1:newPoint];
		}
	} else if (editingPoint.y == 1) {
		[point setControlPoint1:p];
		if (!isCommandDown && editingPoint.x > 1) {
			// Update the previous c2 to keep it in line
			BezierPoint *prevPoint = [bezierPoints objectAtIndex:editingPoint.x - 1];
			float controlLength = NSDistanceFromPointToPoint([prevPoint mainPoint], [prevPoint controlPoint2]);
			if (isShiftDown) {
				controlLength = NSDistanceFromPointToPoint([prevPoint mainPoint], p);
			}
			
			NSPoint trajectory = NSPointSubtractPoint([prevPoint mainPoint], p);
			NSPoint delta = NSScaledPoint(NSNormalizedPoint(trajectory), controlLength);
			NSPoint newPoint = NSPointAddToPoint([prevPoint mainPoint], delta);
			[prevPoint setControlPoint2:newPoint];
		}
	} else if (editingPoint.y == 2) {
		[point setControlPoint2:p];
		if (!isCommandDown && editingPoint.x < [bezierPoints count] - 1) {
			// Update the next c1 to keep it in line
			BezierPoint *nextPoint = [bezierPoints objectAtIndex:editingPoint.x + 1];
			float controlLength = NSDistanceFromPointToPoint([point mainPoint], [nextPoint controlPoint1]);
			if (isShiftDown) {
				controlLength = NSDistanceFromPointToPoint([point mainPoint], p);
			}
			
			NSPoint trajectory = NSPointSubtractPoint([point mainPoint], p);
			NSPoint delta = NSScaledPoint(NSNormalizedPoint(trajectory), controlLength);
			NSPoint newPoint = NSPointAddToPoint([point mainPoint], delta);
			[nextPoint setControlPoint1:newPoint];
		}
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
			
			control1 = NSInterpolatePoints(prevMain, local_point, 0.3);
			control2 = NSInterpolatePoints(control1, local_point, 0.5);
		}
		else if (pointCount > 1) {
			NSPoint prevC2 = [lastPoint controlPoint2];
			NSPoint prevMain = [lastPoint mainPoint];
			
			NSPoint trajectory = NSPointSubtractPoint(prevMain, prevC2);
			control1 = NSPointAddToPoint(prevMain, trajectory);
			
			control2 = NSInterpolatePoints(control1, local_point, 0.5);
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

- (void)deleteBackward:(id)sender {
	if ([bezierPoints count] > 0) {
		[bezierPoints removeLastObject];
		[[self delegate] elementsDidChangeInBezierView:self];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

#define HANDLE_WIDTH 5
#define HANDLE_HEIGHT 5

- (void)drawRect:(NSRect)dirtyRect {
	[[[NSColor redColor] colorWithAlphaComponent:0.6] set];
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
