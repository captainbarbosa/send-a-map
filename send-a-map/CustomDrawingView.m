//
//  CustomDrawingView.m
//  send-a-map
//
//  Created by Nadia Barbosa on 12/19/18.
//  Copyright © 2018 Nadia Barbosa. All rights reserved.
//

#import "CustomDrawingView.h"

@implementation CustomDrawingView
{
    UIBezierPath *path;
}

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [path moveToPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [path addLineToPoint:point];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDrawing)]) {
        [self.delegate didFinishDrawing];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}
@end
