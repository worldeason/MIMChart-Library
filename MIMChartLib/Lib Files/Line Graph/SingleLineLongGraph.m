/*
 Copyright (C) 2011- 2012  Reetu Raj (reetu.raj@gmail.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 and associated documentation files (the “Software”), to deal in the Software without 
 restriction, including without limitation the rights to use, copy, modify, merge, publish, 
 distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
 the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or 
 substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//
//  SingleLineLongGraph.m
//  MIMChartLib
//
//  Created by Reetu Raj on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleLineLongGraph.h"
@interface SingleLineLongGraph()


-(void)_drawAnchorPointsWithColorRed:(float)red Blue:(float)blue Green:(float)green Alpha:(float)alpha;
-(void)_displayXAxisWithStyle:(int)xstyle WithColorRed:(float)red Blue:(float)blue Green:(float)green Alpha:(float)alpha;
-(void)drawVerticalBgLines:(CGContextRef)ctx;
-(void)drawHorizontalBgLines:(CGContextRef)ctx;

@end

@implementation SingleLineLongGraph

@synthesize gridWidth;
@synthesize gridHeight;  
@synthesize tileWidth;
@synthesize tileHeight;
@synthesize scalingX;
@synthesize scalingY;
@synthesize xIsString;

@synthesize colorLineChart;
@synthesize lineBezierPath;
@synthesize verticalLinesVisible;
@synthesize horizontalLinesVisible;
@synthesize widthOfLine;
@synthesize colorOfLine;
@synthesize xValElements;
@synthesize yValElements;
@synthesize xTitleStyle;
@synthesize nonInteractiveAnchorPoints;
@synthesize anchorType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    float r,g,b,a;
    
    if([xValElements count]==0)
        return;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetShouldAntialias(context, NO);
    
    CGAffineTransform flipTransform = CGAffineTransformMake( 1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(context, flipTransform);
    
    
    
    //Clear the background
    //Set Background Clear.    
    CGContextSaveGState(context);
    float k=1.0;
    CGRect aR=self.frame;
    aR.origin.x=0;
    aR.origin.y=0;
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:k green:k blue:k alpha:1.0].CGColor);    
    CGContextAddRect(context, aR);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    

    [self drawVerticalBgLines:context];
    [self drawHorizontalBgLines:context];
    
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    

    
    UIColor *_color=[[UIColor alloc]initWithRed:colorLineChart.red green:colorLineChart.green blue:colorLineChart.blue alpha:colorLineChart.alpha];     
    [_color setStroke];
        

    [lineBezierPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
    r=colorLineChart.red;
    g=colorLineChart.green;
    b=colorLineChart.blue;
    a=colorLineChart.alpha;
    
    [self _drawAnchorPointsWithColorRed:r Blue:b Green:g Alpha:a];
    
}


-(void)drawVerticalBgLines:(CGContextRef)ctx
{
    if(!verticalLinesVisible)
        return;
    
    
    //Draw the Vertical ones
    CGContextBeginPath(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:colorOfLine.red green:colorOfLine.green blue:colorOfLine.blue alpha:colorOfLine.alpha].CGColor);
    CGContextSetLineWidth(ctx, widthOfLine);
    
    int numVertLines=gridWidth/tileWidth;
    
    if(xIsString)
    {
        numVertLines=[xValElements count];
        
        for (int i=0; i<numVertLines; i++) 
        {   
            CGContextMoveToPoint(ctx, i * scalingX,0);
            CGContextAddLineToPoint(ctx, i * scalingX,gridHeight);
        }
        
    }
    else
    {
        for (int i=0; i<numVertLines; i++) 
        {   
            CGContextMoveToPoint(ctx, i*tileWidth,0);
            CGContextAddLineToPoint(ctx, i*tileWidth,gridHeight);
        }
    }
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    
    
}

-(void)drawHorizontalBgLines:(CGContextRef)ctx
{
    if(!horizontalLinesVisible)
        return;
    
    
    
    
    
    //Draw Gray Lines as the markers
    CGContextBeginPath(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:colorOfLine.red green:colorOfLine.green blue:colorOfLine.blue alpha:colorOfLine.alpha].CGColor);
    CGContextSetLineWidth(ctx, widthOfLine);
    int numHorzLines=gridHeight/tileHeight;
    for (int i=0; i<=numHorzLines; i++) {
        
        CGContextMoveToPoint(ctx, 0,i*tileHeight);
        CGContextAddLineToPoint(ctx,gridWidth , i*tileHeight);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    
//    if (xTitleStyle==0)
//        xTitleStyle=X_TITLES_STYLE1;
//    
//    [self _displayXAxisWithStyle:xTitleStyle WithColorRed:colorOfLine.red Blue:colorOfLine.blue Green:colorOfLine.green Alpha:colorOfLine.alpha];
    
}


-(void)_drawAnchorPointsWithColorRed:(float)red Blue:(float)blue Green:(float)green Alpha:(float)alpha
{
    //Remove Any if there
    for (UIView *view in self.subviews) 
    if([view isKindOfClass:[Anchor class]])
    {
        [view removeFromSuperview];
    }
    
    
    for (int l=0; l<[yValElements count]; l++) 
    {   
        float valueY=[[yValElements objectAtIndex:l] floatValue];
        float valueX;
        if(xIsString)
            valueX=(float)l;
        else
            valueX=[[xValElements objectAtIndex:l] floatValue];
        
        float mX=valueX*scalingX;
        float mY=valueY*scalingY;
        mY=gridHeight-mY;
        
        
        Anchor *_anchor=[[Anchor alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _anchor.center=CGPointMake(mX,mY);
        _anchor.type=anchorType;
        
        
        if(!nonInteractiveAnchorPoints)
            _anchor.enabled=YES;
        _anchor.color=[[UIColor alloc]initWithRed:red green:green blue:blue alpha:alpha];
        _anchor.idTag=l;
        _anchor.delegate=self;
        [self addSubview:_anchor];
        [_anchor drawAnchor];
        
    }

}

@end
