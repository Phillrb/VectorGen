//
//  PRBVectorPoint.m
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

#import "PRBVectorPointView.h"

@interface PRBVectorPointView() <PRBVectorPointDetailViewDelegate>

@property(nonatomic, strong) NSClickGestureRecognizer *leftClickRecognizer;
@property(nonatomic, strong) NSClickGestureRecognizer *doubleClickRecognizer;
@property(nonatomic, strong) NSPanGestureRecognizer *panRecognizer;

@end

@implementation PRBVectorPointView

#define kPRBVectorPointDimension 18.0f
#define kPRBVectorPointBorderThickess 2.0f

#define kDefaultAlpha 0.7f

+(id)createVectorAtPoint:(CGPoint)point
{
    PRBVectorPointView *vecPoint = [PRBVectorPointView new];
    CGPoint centerPoint = [PRBVectorPointView shiftViewPoint:point toOriginOfView:vecPoint];
    [vecPoint setFrameOrigin:NSPointFromCGPoint(centerPoint)];
    [vecPoint.detailView setFrameOrigin:NSPointFromCGPoint(centerPoint)];
    
    return vecPoint;
}

+(float)maxAlpha{
    return kDefaultAlpha;
}

-(id)init{
    
    self = [super init];
    
    if(self)
    {
        [self setFrame:NSRectFromCGRect(CGRectMake(0.0f, 0.0f, kPRBVectorPointDimension, kPRBVectorPointDimension))];
        
        [self setAlphaValue:kDefaultAlpha];
    
        //Gestures
        _leftClickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(vectorPointClicked:)];
        [self addGestureRecognizer:_leftClickRecognizer];
        
        _panRecognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(vectorPointPanned:)];
        [self addGestureRecognizer:_panRecognizer];
        
        //Details
        _detailView = [PRBVectorPointDetailView new];
        [_detailView setDelegate:self];
        [_detailView setAlphaValue:1.0f];
    }
    
    return self;
    
}

-(void)vectorPointClicked:(NSGestureRecognizer*)gestureRecognizer{
    
    //All make it current
    [self forceCurrent];
    
}

-(void)vectorPointPanned:(NSGestureRecognizer*)gestureRecognizer{
    
    switch (gestureRecognizer.state) {
        
        case NSGestureRecognizerStateBegan:
        {
            //Highlight
            [self forceCurrent];
        }
            break;
            
        case NSGestureRecognizerStateChanged:
        {
            
            //Don't bother if this is the center one - we dont want it to move - ever!
            if(_isCentralPoint)return;
            
            //Move
            NSPoint newPoint = [gestureRecognizer locationInView:self.superview];
            
            //Test newPoint - only move to valid points
            if([self isPointConvertToVectrexScale:newPoint])
            {
                [self moveToPoint:newPoint];
            }
        }
            break;
            
        default:
            break;
    }
    
}

-(void)forceCurrent{
    _isCurrent = YES;
    
    //show details
    [self showDetail];
    
    //Inform delegate
    if(_delegate && [_delegate respondsToSelector:@selector(vectorPointViewBecameCurrent:)])
    {
        [_delegate vectorPointViewBecameCurrent:self];
    }
}


-(void)moveToPoint:(CGPoint)point{
    
    //Move
    [self goToPoint:point];
    
    //Snap to grid
    if(_delegate && [_delegate respondsToSelector:@selector(vectorPointViewShouldSnapToGrid:)])
    {
        if([_delegate vectorPointViewShouldSnapToGrid:self])
        {
            [self moveToNearestGridPoint];
        }
    }
    
    //Tell any delegates about the move
    if (_delegate && [_delegate respondsToSelector:@selector(vectorPointViewDidMove:)]) {
        
        [_delegate vectorPointViewDidMove:self];
        
    }
}

//Just moves it to point and nothing else
-(void)goToPoint:(CGPoint)point{
    CGPoint centerPoint = [PRBVectorPointView shiftViewPoint:point toOriginOfView:self];
    [self setFrameOrigin:NSPointFromCGPoint(centerPoint)];
}


//Snap to grid
-(void)moveToNearestGridPoint
{
    //TODO Screen View should fulfil this
    //HERE

    int lastDiffX = INT_MAX;
    int gridX = self.viewCenter.x;
    
    int lastDiffY = INT_MAX;
    int gridY = self.viewCenter.y;
    
    
//    for (int x = 0; x <=self.superview.frame.size.width; x+= self.superview.frame.size.width / 20.0f) {
//        int diffX = MAX(abs(x), abs(self.viewCenter.x)) - MIN(abs(x), abs(self.viewCenter.x));
//        if(diffX < lastDiffX ) {
//            lastDiffX = diffX;
//            gridX = x;
//        }
//    }
    
    
    for (int i = 0; i <= 128; i+=10) {
        NSPoint xPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, -127) toViewCenterInView:self.superview]);
        int diffX = MAX(abs(xPoint.x), abs(self.viewCenter.x)) - MIN(abs(xPoint.x), abs(self.viewCenter.x));
        if(diffX < lastDiffX ) {
            lastDiffX = diffX;
            gridX = xPoint.x;
        }
        
        NSPoint yPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(-127, i) toViewCenterInView:self.superview]);
        int diffY = MAX(abs(yPoint.y), abs(self.viewCenter.y)) - MIN(abs(yPoint.y), abs(self.viewCenter.y));
        if(diffY < lastDiffY ) {
            lastDiffY = diffY;
            gridY = yPoint.y;
        }
    }
    
    for (int i = -10; i >= -127; i-=10) {
        NSPoint xPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, 128) toViewCenterInView:self.superview]);
        int diffX = MAX(abs(xPoint.x), abs(self.viewCenter.x)) - MIN(abs(xPoint.x), abs(self.viewCenter.x));
        if(diffX < lastDiffX ) {
            lastDiffX = diffX;
            gridX = xPoint.x;
        }
        
        NSPoint yPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(128, i) toViewCenterInView:self.superview]);
        int diffY = MAX(abs(yPoint.y), abs(self.viewCenter.y)) - MIN(abs(yPoint.y), abs(self.viewCenter.y));
        if(diffY < lastDiffY ) {
            lastDiffY = diffY;
            gridY = yPoint.y;
        }
    }
    
//        NSPoint topPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, -127) toViewCenterInView:self]);
//        NSPoint bottomPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, 128) toViewCenterInView:self]);
//        
//        //Draw a vector
//        [NSBezierPath strokeLineFromPoint:topPoint toPoint:bottomPoint];
//        
//        NSPoint topPoint2 = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(-127, i) toViewCenterInView:self]);
//        NSPoint bottomPoint2 = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(128, i) toViewCenterInView:self]);
//        
//        //Draw a vector
//        [NSBezierPath strokeLineFromPoint:topPoint2 toPoint:bottomPoint2];
//    }
//    
//    for (int i = -10; i >= -127; i-=10) {
    
    
    
    
//    int lastDiffY = INT_MAX;
//    int gridY = self.viewCenter.y;
//    for (int y = 0; y <=self.superview.frame.size.height; y+= self.superview.frame.size.height / 30.0f) {
//        int diffY = MAX(abs(y), abs(self.viewCenter.y)) - MIN(abs(y), abs(self.viewCenter.y));
//        if(diffY < lastDiffY ) {
//            lastDiffY = diffY;
//            gridY = y;
//        }
//    }
    
    [self goToPoint:CGPointMake(gridX, gridY)];
}



- (void)drawRect:(NSRect)dirtyRect {
    
    //Add background -> border
    if (_isCurrent) {
        
        [[NSColor yellowColor] setFill];
        NSRectFill(dirtyRect);
    }
    
    //Background colour
    if(_isCentralPoint)[[NSColor greenColor] setFill];
    else
    {
        if(_isCurrent) [[NSColor clearColor] setFill];
        else [[NSColor yellowColor] setFill];
    }
    
    CGRect innerRectCG = CGRectMake(dirtyRect.origin.x + kPRBVectorPointBorderThickess, dirtyRect.origin.y + kPRBVectorPointBorderThickess, dirtyRect.size.width - (kPRBVectorPointBorderThickess * 2.0f), dirtyRect.size.height - (kPRBVectorPointBorderThickess * 2.0f));
    NSRect innerRect = NSRectFromCGRect(innerRectCG);
    NSRectFill(innerRect);

    [super drawRect:dirtyRect];
}

-(void)setIsCurrent:(BOOL)isCurrent{
    
    _isCurrent = isCurrent;
    [self setNeedsDisplay:YES];
    [self showDetail];
    
}

-(void)showDetail{
    
    //Hide / show details
    [_detailView setAlphaValue:_isCurrent ? 1.0f : 0.0f];

    if(!_detailView.superview)
    {
        [self.superview.superview addSubview:_detailView];
    }
    
}

//Position detail view
-(void)setFrameOrigin:(NSPoint)newOrigin{
    
    [super setFrameOrigin:newOrigin];
    
    [self.detailView setFrameOrigin:[self.superview.superview convertPoint:NSPointFromCGPoint(CGPointMake(newOrigin.x - (_detailView.frame.size.width - self.frame.size.width) / 2.0f, newOrigin.y + 2.0f)) fromView:self.superview]];
}





#pragma mark - coords
//NSView center - public
-(CGPoint)viewCenter{
    
    return CGPointMake((self.frame.origin.x + (self.frame.size.width / 2)),
                       (self.frame.origin.y + (self.frame.size.height / 2)));
}


//For Screen view to use
-(NSString*)coordinateString{
    return [self currentDisplayCoordinate];
}

//For display on detail
-(NSString*)coordString{
    return [self currentDisplayCoordinate];
}

//Used for display in a detail above a point or in the overview text view
-(NSString*)currentDisplayCoordinate{
    
    CGPoint currentVCoord = [self vectrexCoordinateForViewCenter];

    //The first point in the chain nees to show it's position relative to the center
    //all others are relative to their previous point
    if(_delegate && [_delegate respondsToSelector:@selector(previousVectorPointForPoint:)])
    {
        PRBVectorPointView* previousVec = [_delegate previousVectorPointForPoint:self];
        if(previousVec)
        {
            CGPoint prevVCoord = [previousVec vectrexCoordinateForViewCenter];
            return [NSString stringWithFormat:@"%.0f, %.0f",  currentVCoord.y - prevVCoord.y , currentVCoord.x - prevVCoord.x];
        }
    }
   
    //The first point
    return [NSString stringWithFormat:@"%.0f, %.0f", currentVCoord.y, currentVCoord.x];
    
}


//Get location on vectrex scale -128 to 127
-(CGPoint)vectrexCoordinateForViewCenter{
    float coordX = [self coordValueToConvertToVectrexCoordValue:self.viewCenter.x isX:YES];
    float coordY = [self coordValueToConvertToVectrexCoordValue:self.viewCenter.y isX:NO];
    return CGPointMake(coordX, coordY);
}

//Get a single nsview location value converted to vectrex scale -128 to 127
-(float)coordValueToConvertToVectrexCoordValue:(float)point isX:(BOOL)isX{
    return [PRBVectorPointView coordValueToConvertToVectrexCoordValue:point forView:self.superview isX:isX];
}

//Get a single nsview location value converted to vectrex scale -128 to 127 in a particular view
+(float)coordValueToConvertToVectrexCoordValue:(float)point forView:(NSView*)view isX:(BOOL)isX
{
    if(!view) return 0.0f;
    return ((point / (isX ? view.frame.size.width : view.frame.size.height)) * 256) - 128;
}

//Convert a vectrex point (-128 to 127) to NSView coordinate
+(CGPoint)convertVectexCoord:(CGPoint)vectrexCoord toViewCenterInView:(NSView*)view{
    
    float pointX = ((vectrexCoord.x + 128.0f) / 256.0f) * view.frame.size.width;
    float pointY = ((vectrexCoord.y + 128.0f) / 256.0f) * view.frame.size.height;

    return CGPointMake(pointX, pointY);
}

//Move point from bottom left to center - used for connection views to be centralised on drawn vectors
+(CGPoint)shiftViewPoint:(CGPoint)point toOriginOfView:(PRBVectorPointView*)vecPoint
{
    float frameXOffset = NSWidth([vecPoint frame]) / 2.0f;
    float frameYOffset = NSHeight([vecPoint frame]) / 2.0f;
    CGPoint originForCentrePoint = CGPointMake(point.x - frameXOffset, point.y - frameYOffset);
    
    return originForCentrePoint;
}

//Will a point convert to Vectrex scale?
-(BOOL)isPointConvertToVectrexScale:(NSPoint)newPoint{
    
    float coordX = [self coordValueToConvertToVectrexCoordValue:newPoint.x isX:YES];
    float coordY = [self coordValueToConvertToVectrexCoordValue:newPoint.y isX:NO];
    
    if(coordX >= -127 && coordX <= 128
       && coordY >= -127 && coordY <= 128)
    {
        return YES;
    }

    return NO;
}

-(BOOL)isPointConvertToVectrexScale:(NSPoint)newPoint forView:(NSView*)view{
    
    float coordX = [PRBVectorPointView coordValueToConvertToVectrexCoordValue:newPoint.x forView:view isX:YES];
    float coordY = [PRBVectorPointView coordValueToConvertToVectrexCoordValue:newPoint.y forView:view isX:NO];
    
    if(coordX >= -127 && coordX <= 128
       && coordY >= -127 && coordY <= 128)
    {
        return YES;
    }
    
    return NO;
}



#pragma mark - connection view
//Connection point is requesting connect / disconnect
-(void)vectorConnectionViewDidChangeState:(PRBVectorConnectionView *)vectorConnectionView{
    
    BOOL shouldHaveVectorConnectionToPreviousPoint = vectorConnectionView.isConnected;
    [self setIsMoveCommand:!shouldHaveVectorConnectionToPreviousPoint];
    
    if(_delegate && [_delegate respondsToSelector:@selector(vectorPointViewDidChangeState:)])
    {
        [_delegate vectorPointViewDidChangeState:self];
    }

}

@end
