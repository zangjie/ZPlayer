//
//  ZSliderView.h
//  ZJPlayVideo
//
//  Created by zj on 17/6/1.
//  Copyright © 2017年 zj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSlider.h"
@protocol ZSliderViewDlegate <NSObject>
/*
 滑块结束的回调
 */
- (void)sliderMovingEnd:(NSTimeInterval)currentTime;

/*
 滑块值在变化的回调
 */

- (void)sliderValueChanged:(NSTimeInterval)changedTime;
/*
播放暂停键
 */

- (void)playButtonChanged:(UIButton*)button;
/*
全屏
 */
- (void)fullScreenButtonChanged:(UIButton *)button;
/*
 下一集
 */
- (void)nextButtonClick:(UIButton *)button;
/*
 清晰度
 */
- (void)clarityButtonClick:(UIButton *)button;
@end

@interface ZSliderView : UIView

/*
 代理
 */
@property (nonatomic,weak) id<ZSliderViewDlegate>delegate;
/*
 播放总时间
 */
@property (nonatomic, assign) NSTimeInterval sliderTotalTime;
/*
 已经播放的时间
 */
@property (nonatomic, assign) NSTimeInterval currentTime;
/*
 缓冲的时间
 */
@property (nonatomic, assign)NSTimeInterval progressTime;
/*
 缓冲条的颜色,默认lightgray
 */
@property (nonatomic, strong) UIColor *progressColorl;

/*
 进度条的颜色
*/
@property (nonatomic, strong) UIColor *sliderColor;
/*
 缓冲进度view
 */
@property (nonatomic, strong) UIView *progressView;
/*
 播放进度view
 */
@property (nonatomic, strong) ZSlider *sliderView;
/*
 是否在拉动滑块
 */

@property (nonatomic, assign) BOOL isMovingSlider;
/*
 是否是直播
 */
@property (nonatomic, assign) BOOL isLive;

/*
 更新时间.赋值完成以后up一下,可以换成监听
 TODO
 */
- (void)updateTime;
/*
 更新frame
 */
- (void)updateFrame;

//
- (instancetype)initWithFrame:(CGRect)frame isLive:(BOOL)islive;
@end
