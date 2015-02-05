//
//  PRBMasterView.m
//  VectorGen
//
//  Created by Phillip Riscombe-Burton on 25/11/2014.
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

#import "PRBMasterView.h"
#import "PRBVectorScreenView.h"
#import "PRBVectorPointView.h"
#import "PRBVectorConnectionView.h"
#import "PRBImageOverlayView.h"

@implementation PRBMasterView

-(id)init{
    self = [super init];
    
    if(self)
    {
        [self setup];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)coder{
    
    self = [super initWithCoder:coder];
    
    if (self) {
        [self setup];
    }
    
    return self;
    
}

-(id)initWithFrame:(NSRect)frameRect{
    
    self = [super initWithFrame:frameRect];
    
    if (self){
        [self setup];
    }
    
    return self;
    
}
-(void)setup{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageOverlay:) name:kNewImageOverlayNotification object:nil];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - image overlay

-(void)newImageOverlay:(NSNotification*)notif{
    
    //Is this the active window?
    if([NSApplication sharedApplication].keyWindow != [self window]) return;
    
    //Open an image from file
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowedFileTypes:@[@"png",@"jpg",@"gif",@"jpeg"]];
    [panel setAllowsMultipleSelection:NO];
    
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* srcURL = [[panel URLs] objectAtIndex:0];
            
            [self createImageOverlayWithImageAtURL:srcURL];
        }
    }];
}

-(void)createImageOverlayWithImageAtURL:(NSURL*)fileURL{
    
    NSImage* img = [[NSImage alloc] initWithContentsOfURL:fileURL];
    
    float imgWidth = img.size.width;
    float imgHeight = img.size.height;
    
    if (img.size.width > _contentVectorScreenView.frame.size.width) {
        imgWidth = _contentVectorScreenView.frame.size.width;
        imgHeight = imgWidth / (img.size.width / img.size.height);
    }
    
    PRBImageOverlayView* overlay = [[PRBImageOverlayView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, imgWidth, imgHeight)];
    [overlay setImage:img];
    [overlay setDelegate:_contentVectorScreenView];
    
    [self addSubview:overlay positioned:NSWindowAbove relativeTo:[self.subviews lastObject]];
    
}

#pragma mark - drawing
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
