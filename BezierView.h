//
//  BezierView.h
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BezierPoint;

@protocol BezierViewDelegate

- (void) didChangeElementAtIndex:(NSPoint)index byDelta:(NSPoint)point;
- (void) didAddPoints:(NSPointArray)points;
- (NSBezierPath *) path;

@end


@interface BezierView : NSView {
	IBOutlet id<BezierViewDelegate> delegate;
	NSPoint editingPoint;
	NSPoint previousPoint;
	
	BOOL isShiftDown;
}

@property (nonatomic, assign) id<BezierViewDelegate> delegate;

@end
