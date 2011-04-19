//
//  MyDocument.h
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "BezierView.h"

@interface MyDocument : NSDocument <BezierViewDelegate> {	
	BezierView * bezierView;
	NSTextView * bezierCodeView;
	NSPopUpButton *codeOption;
	NSSegmentedControl *originControl;
	NSSegmentedControl *codeStyleControl;
}

@property (nonatomic, retain) IBOutlet BezierView * bezierView;
@property (nonatomic, retain) IBOutlet NSTextView * bezierCodeView;
@property (nonatomic, retain) IBOutlet NSPopUpButton *codeOption;

@property (assign) IBOutlet NSSegmentedControl *originControl;
@property (assign) IBOutlet NSSegmentedControl *codeStyleControl;

- (IBAction) codeOptionChanged:(id)sender;

@end
