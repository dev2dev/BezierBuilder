//
//  MyDocument.h
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@protocol BezierViewDelegate;
@class BezierView;

@interface MyDocument : NSDocument <BezierViewDelegate> {
	NSMutableArray *bezierPoints;
	
	NSBezierPath * bezierPath;
	
	BezierView * bezierView;
	NSTextView * bezierCodeView;
	NSPopUpButton *codeOption;
}

@property (nonatomic, retain) IBOutlet BezierView * bezierView;
@property (nonatomic, retain) IBOutlet NSTextView * bezierCodeView;
@property (nonatomic, retain) IBOutlet NSPopUpButton *codeOption;

- (IBAction) codeOptionChanged:(id)sender;

@end
