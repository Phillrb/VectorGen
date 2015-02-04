//
//  Document.m
//  VectorGen
//
//  Created by Phillip Riscombe-Burton on 24/11/2014.
//  Copyright (c) 2014 Phillip Riscombe-Burton. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "VecDoc.h"
#import "PRBMasterView.h"
#import "PRBVectorScreenView.h"

@interface VecDoc ()

@end

@implementation VecDoc

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    [self addWindowController:[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"]];
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    
    PRBMasterView *masterView = [self.windowForSheet contentView];
    PRBVectorScreenView *screenView = masterView.contentVectorScreenView;
    
    NSMutableString *output = [[NSMutableString alloc] init];
    
    for (PRBVectorPointView* point in screenView.vectorPoints)
    {
        [output appendString:[screenView stringValueForPoint:point]];
    }
    
    return [output dataUsingEncoding:NSUTF8StringEncoding];

}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {

    [self performSelector:@selector(populateWithData:) withObject:data afterDelay:0.5f];
    
    return YES;
}

-(void)populateWithData:(NSData*)data{
    
    PRBMasterView *masterView = [self.windowForSheet contentView];
    PRBVectorScreenView *screenView = masterView.contentVectorScreenView;
    
    NSString* contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [screenView displayPointsFromString:contentString];
}

@end
