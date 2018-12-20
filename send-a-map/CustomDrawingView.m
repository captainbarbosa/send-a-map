//
//  CustomDrawingView.m
//  send-a-map
//
//  Created by Nadia Barbosa on 12/19/18.
//  Copyright © 2018 Nadia Barbosa. All rights reserved.
//

#import "CustomDrawingView.h"

@implementation CustomDrawingView

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];

    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [UIColor.greenColor setFill];
    [path fill];
}

@end
