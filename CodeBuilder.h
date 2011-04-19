//
//  CodeBuilder.h
//  BezierBuilder
//
//  Created by Dave DeLong on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CodeBuilder : NSObject {
	NSArray *bezierPoints;
}

// If yOrigin == 0, a bottom-left coordinate system is used.
// If yOrigin != 0, a top-left coordinate system is used, and bezier
// points (which always use bottom-left are converted before generating
// code.
@property (assign) CGFloat yOrigin;

@property (copy) NSArray *bezierPoints;

- (NSString *) codeForBezierPoints;
- (id) objectForBezierPoints;

// Bezier Points converted for the yOrigin
- (NSArray *)effectiveBezierPoints;

@end
