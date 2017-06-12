//
//  ZSlider.m
//  ZJPlayVideo
//
//  Created by zj on 17/6/5.
//  Copyright © 2017年 zj. All rights reserved.
//

#import "ZSlider.h"

@implementation ZSlider
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, (bounds.size.height-7)/2, bounds.size.width, 7);
}

@end
