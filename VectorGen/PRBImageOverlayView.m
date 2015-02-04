//
//  PRBImageOverlayView.m
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

#import "PRBImageOverlayView.h"
#import "PRBResizeView.h"

@interface PRBImageOverlayView() <PRBResizeViewDelegate>

@property(nonatomic,strong) PRBResizeView *resizeCornerView;
@property(nonatomic,strong) NSPanGestureRecognizer *panRecognizer;

@end

@implementation PRBImageOverlayView

#define kSliderHeight 20.0f
#define kMinWidth 40.0f
#define kMinHeight 40.0f
#define kDefaultAlpha 0.8f

#define kResizeViewDimension 20.0f
#define kImageTag 1000

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
    
    //Slider
    _alphaSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, self.frame.size.width, kSliderHeight)];
    [_alphaSlider setMinValue:0.0f];
    [_alphaSlider setMaxValue:1.0f];
    [_alphaSlider setDoubleValue:kDefaultAlpha];
    [_alphaSlider setEnabled:YES];
    [_alphaSlider setNumberOfTickMarks:10];
    [_alphaSlider setTarget:self];
    [_alphaSlider setAction:@selector(imageSliderDidChange:)];
//    [self addSubview:_alphaSlider];
    
    //resizer
    _resizeCornerView = [[PRBResizeView alloc] initWithFrame:NSMakeRect(self.frame.size.width - kResizeViewDimension, self.frame.size.height - kResizeViewDimension, kResizeViewDimension, kResizeViewDimension)];
    [_resizeCornerView setDelegate:self];
    


}

-(void)setFrame:(NSRect)frame{
    
    //Sensible limits
    if(frame.size.height < kMinHeight || frame.size.width < kMinWidth) return;
    
    [super setFrame:frame];
    
    if(_imageView)
    {
        [_imageView setFrame:self.bounds];
    }
    
    [_alphaSlider setFrame:NSMakeRect(0.0f, 0.0f, self.frame.size.width, kSliderHeight)];
    [_resizeCornerView setFrame:NSMakeRect(self.frame.size.width - kResizeViewDimension, self.frame.size.height - kResizeViewDimension, kResizeViewDimension, kResizeViewDimension)];
}

-(void)setImage:(NSImage *)image{

    if(!_imageView)
    {
        _imageView = [[NSImageView alloc] init];
        [_imageView setImageAlignment:NSImageAlignCenter];
        [_imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [_imageView setAlphaValue:_alphaSlider.doubleValue];
        [_imageView setTag:kImageTag];
        [self addSubview:_imageView positioned:NSWindowBelow relativeTo:[[self subviews] firstObject]];
        
        [_imageView setFrame:self.bounds];
        [self addSubview:_alphaSlider]; //in front
        [self addSubview:_resizeCornerView]; //in front
        
        //Move
        _panRecognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [_imageView addGestureRecognizer:_panRecognizer];
    }
    else
    {
        //TODO ALTER TO FIT THE CURRENT SIZE
        [_imageView setFrame:NSMakeRect(_imageView.bounds.origin.x, _imageView.bounds.origin.y, image.size.width, image.size.height)];
    }
    
    [_imageView setImage:image];
    
}

#pragma mark - slider
-(void)imageSliderDidChange:(NSSlider*)slider{
    
    if(_imageView)
    {
        [_imageView setAlphaValue:[slider doubleValue]];
    }
    
}

#pragma mark - move
NSPoint offsetPoint;
NSPoint currentOrigin;

-(void)didPan:(NSPanGestureRecognizer*)panRecognizer{
    switch (panRecognizer.state) {
        case NSGestureRecognizerStateBegan:
        {
            offsetPoint = [panRecognizer locationInView:self];
        }
            break;
            
        case NSGestureRecognizerStateChanged:
        {
            NSPoint touchPoint = [panRecognizer locationInView:[self superview]];
            [self setFrameOrigin:NSMakePoint(touchPoint.x - offsetPoint.x, touchPoint.y - offsetPoint.y)];
        }
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark - resizer

-(void)resizeView:(PRBResizeView *)resizeView requestsResizeToPoint:(NSPoint)point{
    
    
    [self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, point.x, point.y)];
    
}

////Check to see if tapping points below this image view
//-(NSView*)hitTest:(NSPoint)aPoint {
// 
//    NSView* touchView = [super hitTest:aPoint];
//
//    if (touchView == _imageView) {
//     
//       if(_delegate && [_delegate respondsToSelector:@selector(firstVectorPointAtPoint:)])
//       {
//           //Was the touch above the screen view
//           NSRect vecScreenFrameRec = ((NSView*)_delegate).frame;
//           NSPoint touchPointInSuper = NSMakePoint(aPoint.x + self.frame.origin.x, aPoint.y - self.frame.origin.y);
//           
//           //is touchPointInSuper actually correct for entire window?
//           
//           
//           //PRB THIS IS ALL WRONG!!!
//           
//           //IS THIS TAP WITHIN THE VECTOR SCREEN VIEW?
//           //IS THIS TAP RIGHT ABOVE A VEC POINT?
//            // RETURN POINT
//           
//           
//           
//           
//           
////           
////           //Convert this point to a point in delegate view
////           if (NSPointInRect(touchPointInSuper, screenRect))
////           {
////               
////               NSPoint relativePointSuper = [((NSView*)_delegate) convertPoint:touchPointInSuper fromView:((NSView*)_delegate).superview];
////               
////               //TODO CONVERSION WRONG!!!!!!
////               NSPoint relativePoint = NSMakePoint(relativePointSuper.x - self.frame.origin.x, relativePointSuper.y - self.frame.origin.y);
////               
////               NSLog(@"%.0f,%.0f", relativePoint.x, relativePoint.y);
////               
////               PRBVectorPointView* point = [_delegate firstVectorPointAtPoint:relativePoint];
////               
////               if(point)
////               {
////                   NSLog(@"TOUCHED POINT!!!");
////                   return point;
////               }
////               
////           }
//           
//
//       }
//    }
//    
//    return touchView;
//}

#pragma mark - drawing
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
