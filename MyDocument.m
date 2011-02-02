//
//  MyDocument.m
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "BezierView.h"
#import "BezierPoint.h"

#import "CodeBuilder.h"
#import "NSBezierPathCodeBuilder.h"
#import "CGPathRefCodeBuilder.h"

@implementation MyDocument

@synthesize bezierView, bezierCodeView;
@synthesize codeOption;

- (void) rebuildSteps {
	
	Class builder = [[codeOption selectedItem] representedObject];
		
	[bezierCodeView setString:[builder codeForBezierPoints:bezierPoints]];
}

- (void) codeOptionChanged:(id)sender {
	[self rebuildSteps];
}

- (void) didChangeElementAtIndex:(NSPoint)index byDelta:(NSPoint)point {
	// Get the current points for the curve.
    NSPoint points[3];
    NSBezierPathElement element = [bezierPath elementAtIndex:index.x associatedPoints:points];
	int elemIndex = (element == NSCurveToBezierPathElement ? (int)index.y : 0);
	if (elemIndex >= 0) {
		NSLog(@"%f,%f    %f,%f    %f,%f", points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
		points[elemIndex] = NSPointAddToPoint(points[elemIndex], point);;
	} else {
		for (int i = 0; i < 3; ++i) {
			points[i] = NSPointAddToPoint(points[i], point);
		}
	}
	
    // Update the points.
    [bezierPath setAssociatedPoints:points atIndex:index.x];
	[self rebuildSteps];
	[bezierView setNeedsDisplay:YES];
}

- (void) didAddPoints:(NSPointArray)points {
	BezierPoint *point = [[BezierPoint alloc] init];
	[point setMainPoint:points[0]];
	[point setControlPoint1:points[1]];
	[point setControlPoint2:points[2]];
	[bezierPoints addObject:point];
	[point release];
	
	[self rebuildSteps];
	[bezierView setNeedsDisplay:YES];
}

- (NSBezierPath *) path {
	return [NSBezierPathCodeBuilder objectForBezierPoints:bezierPoints];
}

- (id)init
{
    self = [super init];
    if (self) {
		bezierPoints = [[NSMutableArray alloc] init];    
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	[codeOption removeAllItems];
	
	[codeOption addItemWithTitle:@"NSBezierPath"];
	NSMenuItem *item = [codeOption lastItem];
	[item setRepresentedObject:[NSBezierPathCodeBuilder class]];
	
	[codeOption addItemWithTitle:@"CGMutablePathRef"];
	item = [codeOption lastItem];
	[item setRepresentedObject:[CGPathRefCodeBuilder class]];
	
	[codeOption selectItemAtIndex:0];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

@end
