//
//  CodeBuilder.h
//  BezierBuilder
//
//  Created by Dave DeLong on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CodeBuilder : NSObject {

}

+ (NSString *) codeForBezierPoints:(NSArray *)points;
+ (id) objectForBezierPoints:(NSArray *)points;

@end
