//
//  PRBResizeView.m
//  VectorGen
//
//  Created by Phillip Riscombe-Burton on 01/12/2014.
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

#import "PRBResizeView.h"

@interface PRBResizeView()

@property(nonatomic,strong) NSPanGestureRecognizer *panResize;

@end

@implementation PRBResizeView

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
    if(self)
    {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(NSRect)frameRect{
    
    self = [super initWithFrame:frameRect];
    if(self)
    {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    [self setAlphaValue:0.8f];
    
    _panResize = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeDidPan:)];
    [self addGestureRecognizer:_panResize];
    
}

NSPoint offsetPoint;

-(void)resizeDidPan:(NSPanGestureRecognizer*)panGesture{
    
    switch (panGesture.state) {
        case NSGestureRecognizerStateBegan:
        {
            offsetPoint = [panGesture locationInView:self];
        }
            break;
            
        case NSGestureRecognizerStateChanged:
        {
            NSPoint touchPoint = [panGesture locationInView:[self superview]];
            
            if(_delegate && [_delegate respondsToSelector:@selector(resizeView:requestsResizeToPoint:)])
            {
                [_delegate resizeView:self requestsResizeToPoint:NSMakePoint(touchPoint.x + offsetPoint.x, touchPoint.y + offsetPoint.y)];
            }
        }
            break;
            
        default:
            break;
    }
   
}


#pragma mark - drawing
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor greenColor] setFill];
    NSRectFill(dirtyRect);
}

@end
