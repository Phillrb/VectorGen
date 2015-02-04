//
//  PRBVectorScreenView.m
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

#import "PRBVectorScreenView.h"

//TODO
//TEXTVIEW ON RIGHT - live edit
//Transparent image overlay - needs to allow touches through
//UNDO / REDO
//Delete point
//Simulate button

@interface PRBVectorScreenView() <PRBVectorPointViewDelegate>

@property(nonatomic,assign) IBOutlet NSClickGestureRecognizer *clickRecognizer;
@property(nonatomic,assign) IBOutlet NSTextView *vectorTxt;

@property(nonatomic,assign) BOOL isShowGrid;
@property(nonatomic,assign) BOOL isSnapToGrid;

@end

@implementation PRBVectorScreenView

#define KUserInteractionTime 5.0f

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

-(void)setup{
    NSLog(@"*** Vector document loading ***");
    
    _vectorPoints = [[NSMutableArray alloc] init];
    [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    
    //Settings
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    _isSnapToGrid = [defaults boolForKey:kSnapToGrid];
    _isShowGrid = [defaults boolForKey:kShowGrid];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleGrid:) name:kShowGridNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSnap:) name:kSnapToGridGridNotification object:nil];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Hide / show points
-(void)mouseEntered:(NSEvent *)theEvent{
    
    [self togglePoints:YES];
}

-(void)mouseExited:(NSEvent *)theEvent{
    
    [self togglePoints:NO];
    
}

-(PRBVectorPointView*)previousVectorPointForPoint:(PRBVectorPointView *)vectorPointView
{
    if(_vectorPoints && _vectorPoints.count > 0 && [_vectorPoints containsObject:vectorPointView])
    {
        NSUInteger vecIndex = [_vectorPoints indexOfObject:vectorPointView];

        if(vecIndex > 0 && vecIndex < _vectorPoints.count)
        {
            return [_vectorPoints objectAtIndex:vecIndex - 1];
        }
    }
    
    return nil;
}

-(void)togglePoints:(BOOL)isShow{
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 2.0f;

        for(PRBVectorPointView* point in _vectorPoints)
        {
            [point setAlphaValue:isShow ? [PRBVectorPointView maxAlpha] : 0.0f];
            
            if(point.isCurrent)
            {
                [point.detailView setAlphaValue:isShow ? 1.0f : 0.0f];
            }
            
            if(point.previousConnectionView)
            {
                [point.previousConnectionView setAlphaValue:isShow ? [PRBVectorConnectionView maxAlpha] : 0.0f];
            }
            
        }
        
    } completionHandler:nil];
    
}

#pragma mark - touch
-(IBAction)vectorScreenTapped:(NSGestureRecognizer*)gestureRecognizer{
    
    switch (gestureRecognizer.state) {

        case NSGestureRecognizerStateEnded:
        {
            [self createNewVectorAtPoint:[gestureRecognizer locationInView:self] isMove:NO];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)createNewVectorAtPoint:(CGPoint)point isMove:(BOOL)isMove{
    
    //Create a point and add it to the view
    PRBVectorPointView* newVectorPoint = [PRBVectorPointView createVectorAtPoint:point];
    
    //Is it a valid point?
    if(![newVectorPoint isPointConvertToVectrexScale:NSPointFromCGPoint(point) forView:self])
    {
       return;
    }
    
    //Valid - so add it
    [newVectorPoint setDelegate:self];
    [self addSubview:newVectorPoint];
    
    //Snap
    if(_isSnapToGrid)[newVectorPoint moveToNearestGridPoint];
    
    
    //Where is the context point?
    PRBVectorPointView *contextPoint = nil;
    for(PRBVectorPointView* point in _vectorPoints)
    {
        if(point.isCurrent)
        {
            contextPoint = point;
            break;
        }
    }
    
    BOOL isFirstPoint = NO;
    
    //Move: First one is always a move command - overwrite
    if (_vectorPoints.count == 0 && !CGPointEqualToPoint(point, CGPointZero))
    {
        isFirstPoint = YES;
        
        PRBVectorPointView* primaryVectorPoint = [PRBVectorPointView createVectorAtPoint:NSMakePoint(NSWidth(self.frame) / 2.0f, NSHeight(self.frame) / 2.0f)];
        [primaryVectorPoint setIsCentralPoint:YES];
        [primaryVectorPoint setDelegate:self];
        [self addSubview:primaryVectorPoint];
        
        [primaryVectorPoint setIsMoveCommand:YES];
        if(_isSnapToGrid)[primaryVectorPoint moveToNearestGridPoint];
        [_vectorPoints addObject:primaryVectorPoint];
        
        contextPoint = primaryVectorPoint;
        [newVectorPoint setIsMoveCommand:YES];
    }
    else
    {
        [newVectorPoint setIsMoveCommand:isMove];
    }
    

        //Connection points
        if(!contextPoint) contextPoint = [_vectorPoints lastObject];
        
        //Is new point at start of list?
        if(_vectorPoints.count > 1 && contextPoint == [_vectorPoints firstObject])
        {
            //Put new point before the first point - so connection point will be before this point
            [self createNewConnectionViewBetweenSrcPoint:newVectorPoint andDstPoint:contextPoint];
            
            //Alter move commands for first in list
            if (contextPoint.isMoveCommand) [contextPoint setIsMoveCommand:NO];
            [newVectorPoint setIsMoveCommand:YES];
        }
        else
        {
            //Update next connection point
            if(contextPoint != [_vectorPoints lastObject])
            {
                [newVectorPoint setNextConnectionView:contextPoint.nextConnectionView];
                [self updateConnectionViewPosition:newVectorPoint.nextConnectionView betweenSrcPoint:newVectorPoint andDstPoint:[_vectorPoints objectAtIndex:[_vectorPoints indexOfObject:contextPoint] + 1]];
            }
             
            //Put new connection point after this point
            [self createNewConnectionViewBetweenSrcPoint:contextPoint andDstPoint:newVectorPoint];
            
            //First is a move
            if(isFirstPoint)
            {
                [newVectorPoint.previousConnectionView setIsConnected:NO];
            }
        }
//    }
    
    //Add it to the array of vector points
    if(!contextPoint || (contextPoint && contextPoint == [_vectorPoints lastObject]))
    {
        //Add on end
        [_vectorPoints addObject:newVectorPoint];
    }
    else if(contextPoint && contextPoint == [_vectorPoints firstObject])
    {
        //Add at start
        [_vectorPoints insertObject:newVectorPoint atIndex:0];
    }
    else if(contextPoint)
    {
        //Add after context point
        [_vectorPoints insertObject:newVectorPoint atIndex:[_vectorPoints indexOfObject:contextPoint] + 1];
    }
    
    //Highlight new point
    [self unhighlightCurrentPointAvoiding:nil];
    [newVectorPoint setIsCurrent:YES];

    //Connect the dots!
    [self redrawVectors];
    
}

-(void)vectorPointViewDidMove:(PRBVectorPointView *)vectorPointView{

    [self moveConnectionViewsForPoint:vectorPointView];
    [self redrawVectors];
}

-(void)vectorPointViewBecameCurrent:(PRBVectorPointView *)vectorPointView{
    [self unhighlightCurrentPointAvoiding:vectorPointView];
    [self redrawVectors];
}

-(void)vectorPointViewDidChangeState:(PRBVectorPointView *)vectorPointView{
    [self redrawVectors];
}

-(BOOL)vectorPointViewShouldSnapToGrid:(PRBVectorPointView*)vectorPointView
{
    return _isSnapToGrid;
}

-(void)unhighlightCurrentPointAvoiding:(PRBVectorPointView *)avoidPointView{
    NSArray *tmpVecs = _vectorPoints;
    for (PRBVectorPointView* vectorPoint in tmpVecs) {
        if( (avoidPointView == nil || vectorPoint != avoidPointView) && vectorPoint.isCurrent)
        {
            [vectorPoint setIsCurrent:NO];
        }
    }
}





-(void)redrawVectors
{
    [self setNeedsDisplay:YES];
}

-(NSString*)stringValueForPoint:(PRBVectorPointView*)point{

return [NSString stringWithFormat:@"%@%@, %@,",
    (_vectorPoints.count > 0 && [_vectorPoints objectAtIndex:0] == point) ? @"" : @"\n",
    point.isMoveCommand ? @"0": @"255",
        [point coordinateString]];
}

-(void)drawVectorFromPoint:(PRBVectorPointView*)srcVector toPoint:(PRBVectorPointView*)dstVector{
    
    //Draw a vector
    [NSBezierPath strokeLineFromPoint:srcVector.viewCenter toPoint:dstVector.viewCenter];
    
}


-(void)createNewConnectionViewBetweenSrcPoint:(PRBVectorPointView*)srcPoint andDstPoint:(PRBVectorPointView*)dstPoint{
    
    PRBVectorConnectionView* connectionView = [PRBVectorConnectionView new];
    
    [self updateConnectionViewPosition:connectionView betweenSrcPoint:srcPoint andDstPoint:dstPoint];
    
    [self addSubview:connectionView];
    [dstPoint setPreviousConnectionView:connectionView];
    [srcPoint setNextConnectionView:connectionView];
    [connectionView setDelegate:dstPoint];
}

-(void)moveConnectionViewsForPoint:(PRBVectorPointView*)point{
    
    NSUInteger index = [_vectorPoints indexOfObject:point];

    //Move previous connection view
    if(index > 0)
    {
        PRBVectorPointView* previousPointView = [_vectorPoints objectAtIndex: index - 1];
        if(previousPointView)
        {
            [self updateConnectionViewPosition:point.previousConnectionView betweenSrcPoint:previousPointView andDstPoint:point];
        }
    }
    
    //Move next connection view
    if(index < _vectorPoints.count - 1)
    {
        PRBVectorPointView* nextPointView = [_vectorPoints objectAtIndex: index + 1];
        if(nextPointView)
        {
            [self updateConnectionViewPosition:point.nextConnectionView betweenSrcPoint:point andDstPoint:nextPointView];
        }
    }
}

//Move the connection point
-(void)updateConnectionViewPosition:(PRBVectorConnectionView*)connectionView betweenSrcPoint:(PRBVectorPointView*)srcPoint andDstPoint:(PRBVectorPointView*)dstPoint{
    
    if(!connectionView || !srcPoint || !dstPoint) return;
    
    float newX = MIN(srcPoint.viewCenter.x, dstPoint.viewCenter.x) + ((MAX(srcPoint.viewCenter.x, dstPoint.viewCenter.x) - MIN(srcPoint.viewCenter.x, dstPoint.viewCenter.x)) / 2.0f);
    float newY = MIN(srcPoint.viewCenter.y, dstPoint.viewCenter.y) + ((MAX(srcPoint.viewCenter.y, dstPoint.viewCenter.y) - MIN(srcPoint.viewCenter.y, dstPoint.viewCenter.y)) / 2.0f);
    
    [connectionView setFrameOrigin:NSPointFromCGPoint(CGPointMake( newX - connectionView.frame.size.width / 2.0f, newY - connectionView.frame.size.height / 2.0f))];
    
}

-(void)displayPointsFromString:(NSString *)pointsStr{
    
    //Clear existing points
    for (PRBVectorPointView *point in _vectorPoints) {
        
        if(point.previousConnectionView) [point.previousConnectionView removeFromSuperview];
        if(point.detailView) [point.detailView removeFromSuperview];
        [point removeFromSuperview];
        
    }
    
    [_vectorPoints removeAllObjects];
    
    
    //Turn off Snap To Grid whilst adding from file
    BOOL turnSnapToGridBackOn = NO;
    if(_isSnapToGrid)
    {
        _isSnapToGrid = NO;
        turnSnapToGridBackOn = YES;
    }
    
    NSArray* strPointsArr = [pointsStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //Prepare last point - for relative positioning
    int pos = 0;
    CGPoint lastVecCoord = CGPointZero;
    
    for (NSString *strPoint in strPointsArr) {
        
        NSArray* pointAr = [strPoint componentsSeparatedByString:@","];
        
        NSMutableArray* coordAr = [[NSMutableArray alloc] initWithCapacity:3];
        
        if(pointAr.count >= 3)
        {
            for (NSString *coord in pointAr)
            {
                NSNumber* num = [NSNumber numberWithInteger:coord.integerValue];
                [coordAr addObject:num];
            }
            
            //Convert
            NSInteger intX = ((NSNumber*)[coordAr objectAtIndex:2]).integerValue;
            NSInteger intY = ((NSNumber*)[coordAr objectAtIndex:1]).integerValue;
            CGPoint vecCoord = CGPointMake(intX, intY);
            
            //skip first point if it's origin! Dealt with in point creation.
            if (pos == 0 && CGPointEqualToPoint(vecCoord, CGPointZero))
            {
                continue;
            }
            
            //Prepare point
            CGPoint viewPoint = CGPointZero;
            
            //First point is relative to middle
            if(pos == 0)
            {
                viewPoint = [PRBVectorPointView convertVectexCoord:vecCoord toViewCenterInView:self];
                lastVecCoord = vecCoord;
            }
            else
            {
                //Other points relative to last point
                CGPoint absVectrexCoord = CGPointMake(lastVecCoord.x + vecCoord.x, lastVecCoord.y + vecCoord.y);
                viewPoint = [PRBVectorPointView convertVectexCoord:absVectrexCoord toViewCenterInView:self];
                lastVecCoord = absVectrexCoord;
                
            }
            
            //Move?
            NSInteger intMove = ((NSNumber*)[coordAr objectAtIndex:0]).integerValue;
            BOOL isMove =isMove = intMove == 0;
            
            //Create the vector point and add it
            [self createNewVectorAtPoint:viewPoint isMove:isMove];
        }
        
        pos++;
    }
    
    //Turn Snap to Grid Back On
    if(turnSnapToGridBackOn)
    {
        _isSnapToGrid = YES;
    }
    
}

#pragma mark - grid
-(void)toggleGrid:(NSNotification*)notif{
    BOOL isShow = ((NSNumber*)[[notif userInfo] objectForKey:kShowValue]).boolValue;
    _isShowGrid = isShow;
    
    [[NSUserDefaults standardUserDefaults] setBool:_isShowGrid forKey:kShowGrid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self redrawVectors];
    
}

-(void)toggleSnap:(NSNotification*)notif{
    BOOL isSnap = ((NSNumber*)[[notif userInfo] objectForKey:kSnapValue]).boolValue;
    _isSnapToGrid = isSnap;
    
    [[NSUserDefaults standardUserDefaults] setBool:_isSnapToGrid forKey:kSnapToGrid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - image overlay
-(PRBVectorPointView*)firstVectorPointAtPoint:(NSPoint)point{
    
    NSArray* vecPoints = [NSArray arrayWithArray:_vectorPoints];
    
//    NSLog(@"POINT: %.0f,%.0f", point.x, point.y);
    
    for (PRBVectorPointView* vec in vecPoints) {
        
//        NSLog(@"VEC: %.2f, %.2f", vec.frame.origin.x, vec.frame.origin.y);
        
        if(NSPointInRect(point, vec.frame) )
        {
            return vec;
        }
        
    }
    
    return nil;
}

#pragma mark - draw
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    //Black background
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    
    //Grid
    [self drawGridIfNeeded];
    
    //White vectors
    [[NSColor whiteColor] setStroke];
    
    //Connect the dots!
    PRBVectorPointView *previousVectorPoint = nil;
    NSArray *tmpVecs = _vectorPoints;
    
    //Clear text view
    [_vectorTxt setString:@""];
    
    for (PRBVectorPointView* vectorPoint in tmpVecs) {
        
        [_vectorTxt setString:[_vectorTxt.string stringByAppendingString:[self stringValueForPoint:vectorPoint]]];
        
        //Only draw a vector between valid points
        if (!vectorPoint.isMoveCommand && previousVectorPoint) {
            [self drawVectorFromPoint:previousVectorPoint toPoint:vectorPoint];
        }
        
        //Move on
        previousVectorPoint = vectorPoint;
    }
    
    if (tmpVecs.count > 0) {
        [_vectorTxt setString:[_vectorTxt.string stringByAppendingString:@"\n1,"]];
    }
    
}

-(void)drawGridIfNeeded
{
    [[NSColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:.3f] setStroke];
    
    if(_isShowGrid)
    {
        for (int i = 0; i <= 128; i+=10) {
            
            NSPoint topPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, -127) toViewCenterInView:self]);
            NSPoint bottomPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, 128) toViewCenterInView:self]);
            
            //Draw a vector
            [NSBezierPath strokeLineFromPoint:topPoint toPoint:bottomPoint];
            
            NSPoint topPoint2 = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(-127, i) toViewCenterInView:self]);
            NSPoint bottomPoint2 = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(128, i) toViewCenterInView:self]);
            
            //Draw a vector
            [NSBezierPath strokeLineFromPoint:topPoint2 toPoint:bottomPoint2];
        }
        
        for (int i = -10; i >= -127; i-=10) {
            
            NSPoint topPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, -127) toViewCenterInView:self]);
            NSPoint bottomPoint = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(i, 128) toViewCenterInView:self]);
            
            //Draw a vector
            [NSBezierPath strokeLineFromPoint:topPoint toPoint:bottomPoint];
            
            NSPoint topPoint2 = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(-127, i) toViewCenterInView:self]);
            NSPoint bottomPoint2 = NSPointFromCGPoint([PRBVectorPointView convertVectexCoord:CGPointMake(128, i) toViewCenterInView:self]);
            
            //Draw a vector
            [NSBezierPath strokeLineFromPoint:topPoint2 toPoint:bottomPoint2];
        }
        
        
//        for (int x = 0; x <=self.frame.size.width; x+= self.frame.size.width / 20.0f) {
//            
//            NSPoint topPoint = NSPointFromCGPoint(CGPointMake(x, 0.0f));
//            NSPoint bottomPoint = NSPointFromCGPoint(CGPointMake(x, self.frame.size.height));
//            
//            //Draw a vector
//            [NSBezierPath strokeLineFromPoint:topPoint toPoint:bottomPoint];
//        }
//        
//        for (int y = 0; y <=self.frame.size.height; y+= self.frame.size.height / 30.0f) {
//            
//            NSPoint leftPoint = NSPointFromCGPoint(CGPointMake(0.0f, y));
//            NSPoint rightPoint = NSPointFromCGPoint(CGPointMake(self.frame.size.width, y));
//            
//            //Draw a vector
//            [NSBezierPath strokeLineFromPoint:leftPoint toPoint:rightPoint];
//        }
    }
}

@end
