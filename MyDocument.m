//
//  MyDocument.m
//  BezierBuilder
//
//  Created by Dave DeLong on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "BezierPoint.h"

#import "CodeBuilder.h"
#import "NSBezierPathCodeBuilder.h"
#import "CGPathRefCodeBuilder.h"

@implementation MyDocument

@synthesize bezierView, bezierCodeView;
@synthesize codeOption;

- (void) rebuildSteps {
	
	Class builder = [[codeOption selectedItem] representedObject];
		
	[bezierCodeView setString:[builder codeForBezierPoints:[bezierView bezierPoints]]];
}

- (void) codeOptionChanged:(id)sender {
	[self rebuildSteps];
}

- (void) elementsDidChangeInBezierView:(BezierView *)view {
	[self rebuildSteps];
	[bezierView setNeedsDisplay:YES];
}

- (id)init
{
    self = [super init];
    if (self) {
 
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
