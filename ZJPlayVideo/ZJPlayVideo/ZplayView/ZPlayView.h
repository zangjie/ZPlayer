//
//  ZPlayView.h
//  ZJPlayVideo
//
//  Created by zj on 17/6/1.
//  Copyright © 2017年 zj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSliderView.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

typedef NS_ENUM(NSInteger, ZInterfaceOrientationType) {
    
    ZInterfaceOrientationUp          = 0,//home键在下面
    ZInterfaceOrientationLandscapeLeft      = 1,//home键在左边
    ZInterfaceOrientationLandscapeRight     = 2,//home键在右边
    ZInterfaceOrientationUnknown            = 3,//未知方向
    ZInterfaceOrientationDown= 4,//home键在上面
};

typedef NS_ENUM(NSInteger, ZVideoMoveBackState) {
    ZVideoMoveBackStateForward           = 0,//前进
    ZVideoMoveBackStateBack              = 1,//后退
};

@protocol ZPlayViewDelegate <NSObject>

/**
 播放还是暂停的回调
 
 @param state 视屏的状态
 */
- (void)playStateChanged:(IJKMPMoviePlaybackState)state;

/*全屏或者小平的回调*/
- (void)fullScreen;

/**
 滑块手势的回调
 @param time  当前的时间
 */

- (void)playCurrentTime:(NSTimeInterval)time;
/**
 滑动手势的回调

 @param changedTime 改变的时间 有正负数
 @param player      播放器回调, 当前时间是 player.currentPlaybackTime
 */
- (void)slidingScreenChangeTime:(NSTimeInterval)changedTime piayer:(IJKFFMoviePlayerController *)player ;


/**
 一直在变化的滑条时间

 @param changedTime 当前的时间
 */
- (void)sliderValueChangedInPlayView:(NSTimeInterval)changedTime;

/**
 双击回调
 */
- (void)doubleClick;

/**
 单击
 */
- (void)oneClick;

/*
 下一集的回调
 */
- (void)nextPlayUrlPlay:(NSString *)currtenPlayUrl isFullScreen:(ZInterfaceOrientationType)type ;

/*
 切换高清必须要做的 具体看我的例子 是datasource
 */


@end

@protocol ZPlayViewChangeClarityDataSoure <NSObject>

/**
 清晰度

 @return 需要的高清链接
 */
- (NSString *)changeClarity;


/**
 下一曲

 @return 下一曲的链接
 */
- (NSString *)nextPlayUrl:(NSString *)currentPlayURL;

@end


@interface ZPlayView : UIView<IJKMediaPlayback>
@property (nonatomic, assign) BOOL isHidden;//交互界面是否hidden

/*
 delegate
 */
@property (nonatomic, weak) id<ZPlayViewDelegate>delegate;
/*
 datasource
 */
@property (nonatomic, weak) id<ZPlayViewChangeClarityDataSoure>dataSource;
/*
 进度条
 */
@property (nonatomic, strong) ZSliderView *sliderConrtoller;

/*
 屏幕方向
 */
@property (nonatomic, assign) ZInterfaceOrientationType type;
/*
 该视屏具有的清晰度
 */
@property (nonatomic, copy) NSArray <NSString *> *clarityArray;

/**
 初始化播放器

 @param playurl   播放链接
 @param isLive 是否直播
 */
- (void)startWithPlayUrl:(NSString *)playurl
                  isLive:(BOOL)isLive;

//播放
- (void)play;
//暂停
- (void)pause;

//停止
- (void)stop;
//移除
- (void)removePlayer;


@end
