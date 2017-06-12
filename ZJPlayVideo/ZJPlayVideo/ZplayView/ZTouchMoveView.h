//
//  ZTouchMoveView.h
//  ZJPlayVideo
//
//  Created by zj on 17/6/4.
//  Copyright © 2017年 zj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TouchNumberForType) {
    TouchNumberForTypeClick          = 0,//单击
    TouchNumberForTypeDoubleclick    = 1,//双击
};


@protocol ZTouchMoveViewDelegate <NSObject>

/**
 偏移的秒数
 @param seconds 秒数 (有负数和正数)
 */
- (void)moveOffsetforSeconds:(NSTimeInterval)seconds;

/**
 音量改变

 @param value        改变量
 @param currentValue 当前量
 */
- (void)changeVlumeValue:(CGFloat)value currentValue:(CGFloat)currentValue;


/**
 亮度改变

 @param value        改变值
 @param currentValue 当前量
 */
- (void)changeBrightnessValue:(CGFloat)value currentValue:(CGFloat)currentValue;

/*单击和双击触摸的返回 双击暂停或者播放
 */
-(void)touchTheView:(TouchNumberForType)type;
@end

@interface ZTouchMoveView : UIView

/*
 delegate
 */
@property (nonatomic, weak) id<ZTouchMoveViewDelegate>delegate;

/*
 音量
*/

@end
