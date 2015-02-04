//
//  PRBVectorPointDetailView.m
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

#import "PRBVectorPointDetailView.h"

@implementation PRBVectorPointDetailView

#define kPRBVectorPointDetailWidth 70.0f
#define kPRBVectorPointDetailHeight 40.0f

-(instancetype)init{
    
    self = [super init];
    
    if(self)
    {
        [self setFrame:NSRectFromCGRect(CGRectMake(0.0f, 0.0f, kPRBVectorPointDetailWidth, kPRBVectorPointDetailHeight))];
        
        _txtCoord = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0.0f, 0.0f, kPRBVectorPointDetailWidth, kPRBVectorPointDetailHeight / 2.0f))];
        [_txtCoord setAlignment:NSCenterTextAlignment];
        [_txtCoord setBackgroundColor:[NSColor clearColor]];
        [_txtCoord setTextColor:[NSColor whiteColor]];
        
        _txtCoord.bezeled         = NO;
        _txtCoord.editable        = NO;
        _txtCoord.drawsBackground = NO;
        
        [[_txtCoord cell] setBackgroundStyle:NSBackgroundStyleRaised];
        
        [self addSubview:_txtCoord];
    }
    
    return self;
    
}


//NO TOUCHES!
-(NSView*)hitTest:(NSPoint)aPoint{
    return nil;
}


-(void)setFrameOrigin:(NSPoint)newOrigin{
    
    [super setFrameOrigin:NSPointFromCGPoint(CGPointMake(newOrigin.x, newOrigin.y + 10.0f))];
    
    //Update co-ord
    if(_delegate && [_delegate respondsToSelector:@selector(coordString)])
    {
        [_txtCoord setStringValue:[_delegate coordString]];
    }
    
}

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
    // do other drawings
}



@end
