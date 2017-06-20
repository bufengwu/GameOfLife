//
//  BGView.m
//  GameOfLife
//
//  Created by XYDM001 on 2017/4/10.
//  Copyright © 2017年 xydSDK. All rights reserved.
//

#import "FarmlandView.h"

@implementation FarmlandView

- (void)drawRect:(CGRect)rect {
    CGFloat cellWidth = self.frame.size.width/_mapArray.count;
    CGColorRef liveColor = [UIColor greenColor].CGColor;
    CGColorRef deathColor = [UIColor brownColor].CGColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int i = 0; i < _mapArray.count; i++) {
        for (int j = 0; j < _mapArray.count; j++) {
            CGContextSetFillColorWithColor(context, [_mapArray[i][j] boolValue] ? liveColor : deathColor);  //填充颜色
            CGContextAddRect(context,CGRectMake(cellWidth * i, cellWidth * j, cellWidth, cellWidth));       //画方框
            CGContextDrawPath(context, kCGPathFillStroke);  //绘画路径
        }
    }
}

- (void)setMapArray:(NSArray<NSArray *> *)mapArray {
    _mapArray = mapArray;
    [self setNeedsDisplay];
}

@end

