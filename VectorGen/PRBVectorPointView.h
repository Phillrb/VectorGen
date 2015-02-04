//
//  PRBVectorPoint.h
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

#import <Cocoa/Cocoa.h>
#import "PRBVectorConnectionView.h"
#import "PRBVectorPointDetailView.h"

@class PRBVectorPointView;

@protocol PRBVectorPointViewDelegate <NSObject>

-(void)vectorPointViewDidMove:(PRBVectorPointView*)vectorPointView;
-(void)vectorPointViewBecameCurrent:(PRBVectorPointView*)vectorPointView;
-(void)vectorPointViewDidChangeState:(PRBVectorPointView*)vectorPointView;
-(BOOL)vectorPointViewShouldSnapToGrid:(PRBVectorPointView*)vectorPointView;

-(PRBVectorPointView*)previousVectorPointForPoint:(PRBVectorPointView*)vectorPointView;

@end

@interface PRBVectorPointView : NSView <PRBVectorConnectionViewDelegate>

@property(nonatomic,assign) id<PRBVectorPointViewDelegate>delegate;
@property(nonatomic,assign) BOOL isMoveCommand;
@property(nonatomic,assign) BOOL isCurrent;
@property(nonatomic, assign) BOOL isCentralPoint;
@property(nonatomic, strong) PRBVectorConnectionView  *previousConnectionView;
@property(nonatomic, strong) PRBVectorConnectionView  *nextConnectionView;
@property(nonatomic, strong) PRBVectorPointDetailView *detailView;

+(float)maxAlpha;
+(id)createVectorAtPoint:(CGPoint)point;
-(void)moveToPoint:(CGPoint)point;
-(void)moveToNearestGridPoint; //for snap to grid

//Get the center of the view
-(CGPoint)viewCenter;

//Display coordinate string
-(NSString*)coordinateString;

//Will a view pos convert to vectrex scale
-(BOOL)isPointConvertToVectrexScale:(NSPoint)newPoint;
-(BOOL)isPointConvertToVectrexScale:(NSPoint)newPoint forView:(NSView*)view;

//Convert view coord to vectrex coord
+(float)coordValueToConvertToVectrexCoordValue:(float)point forView:(NSView*)view isX:(BOOL)isX;

//Convert vectrex coord to view coord
+(CGPoint)convertVectexCoord:(CGPoint)vectrexCoord toViewCenterInView:(NSView*)view;
@end
