//
//  BezierView.h
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BezierView;

@protocol BezierViewDelegate

- (void) elementsDidChangeInBezierView:(BezierView *)bezierView;

@end


@interface BezierView : NSView {
	NSMutableArray *bezierPoints;
	NSPoint editingPoint;
	
	IBOutlet id<BezierViewDelegate> delegate;
}

@property (nonatomic, assign) id<BezierViewDelegate> delegate;
@property (nonatomic, readonly) NSArray * bezierPoints;

@end
