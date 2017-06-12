//
//  ZPlayView.m
//  ZJPlayVideo
//
//  Created by zj on 17/6/1.
//  Copyright © 2017年 zj. All rights reserved.
//

#define HEIGHTSCANLE_BOTTOMVIEW 50
#define HEIGHTSCANLE_BOTTOMVIEW_SIX self.frame.size.height/6

#define COLOR_CONRTOLVIEW [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]

#import "ZPlayView.h"
#import "ZTouchMoveView.h"
#import <Masonry.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

@interface ZPlayView()<ZSliderViewDlegate,ZTouchMoveViewDelegate,ZPlayViewChangeClarityDataSoure>
{

    BOOL _isTopAndBottomHidden;//交互界面是否hidden
    long long _oldIbytes;
    NSTimeInterval _currentTimeForClarity;
    
}
//test------
@property (nonatomic, strong) UILabel *testlable;
@property (nonatomic, strong) UIButton *buttonNext;
@property (nonatomic, strong) UILabel *lableTitle;
@property (nonatomic, strong) UIImageView *imagecurrentImage;
@property (nonatomic, strong) UIButton *buttonClarity;//清晰度
//----
/*
 是否是直播
 */
@property (nonatomic, assign) BOOL isLive;
/*
 视屏底部的交互区
 */
@property (nonatomic, strong) UIView *bottomInteractionView;
/*视频上部的交互区*/
@property (nonatomic, strong) UIView *topInteractionView;

/*
 播放的链接
 */
@property (nonatomic, copy) NSString *currentPlayUrl;
/*
 ijk播放主体
*/
@property (nonatomic, strong) IJKFFMoviePlayerController *ZPlay;

/*
 播放的控制baseView
 */
@property (nonatomic, strong) ZTouchMoveView *videoControllView;
/*
 当前秒数的定时器
 */
@property (nonatomic, strong) NSTimer *timer;

/*初始化的frame
 */
@property (nonatomic, assign) CGRect oldFrame;
/*
 播放/暂停
 */
@property (nonatomic, strong) UIButton *playStateButton;
/*
 全屏按钮
 */
@property (nonatomic, strong) UIButton *fullScreenButton;

/*
 清晰度的数组展示的View
 */
@property (nonatomic, strong)UIView *clarityView;
/*
 停止或者切换清晰度的切图
 */
@property (nonatomic, strong)UIImageView *cutImageView;

@end

@implementation ZPlayView

- (void)dealloc
{
    NSLog(@"🎈 被释放了");
    [self removeMovieNotificationObservers];
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

//定时器:用来读取当前秒数,一秒一次
- (NSTimer *)timer
{
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateEvent)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return _timer;
}

- (instancetype)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame])
    {
    
        self.oldFrame = self.frame;

    }
    return self;
}
- (void)startWithPlayUrl:(NSString *)playurl
                  isLive:(BOOL)isLive
{
    self.backgroundColor = [UIColor blackColor];
    self.ZPlay?[self removePlayer]:nil;
    self.isLive  = isLive;
    self.currentPlayUrl = playurl;
    [self orientationChanged];

    [self setUpUI];
    

}
#pragma mark -----配置UI界面
- (void)setUpUI
{
 
    [self setUpIJKPlay];
    [self setUpVideoContorllerview];
    [self setUpVideoStateBack];
    [self updateFrameIsUpdata:NO];
}
- (void)setUpIJKPlay
{


    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setFormatOptionIntValue:1024 * 16 forKey:@"probsize"];
    [options setFormatOptionIntValue:50000 forKey:@"analyzeduration"];
    [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];//0 是软解 1是只能硬解 2是硬解 不同之处是软解靠cpu 硬解靠GPU
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter"];
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame"];
    
    if(_isLive)
    {
        [options setPlayerOptionIntValue:3000 forKey:@"max_cached_duration"];   // 最大缓存大小是3秒，可以依据自己的需求修改
        [options setPlayerOptionIntValue:1 forKey:@"infbuf"];  // 无限读
        [options setPlayerOptionIntValue:0 forKey:@"packet-buffering"];
    }
    else
    {
        [options setPlayerOptionIntValue:0 forKey:@"max_cached_duration"];   
        [options setPlayerOptionIntValue:0 forKey:@"infbuf"];
        [options setPlayerOptionIntValue:1 forKey:@"packet-buffering"];
    }
//    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];//视屏过大音频不同步的问题,但是打开的话在暂停播放的时候会有卡顿所以先关了 
    self.ZPlay = [[IJKFFMoviePlayerController alloc]initWithContentURLString:self.currentPlayUrl withOptions:options];
    self.ZPlay.shouldAutoplay = YES;
    self.ZPlay.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.ZPlay.shouldShowHudView = NO;
    self.autoresizesSubviews = YES;
    [self addSubview:self.ZPlay.view];//吧播放的view放到我们现在这个界面上
    [self.ZPlay prepareToPlay];
    
}

- (void)setUpVideoContorllerview
{
    
    self.videoControllView = [[ZTouchMoveView alloc]initWithFrame:self.bounds];//所有交互的父控件
    self.videoControllView.delegate = self;
    [self addSubview:self.videoControllView];
    
#pragma mark--------控制区域的UI-------------------
    self.bottomInteractionView = [[UIView alloc]initWithFrame:CGRectZero];
    self.bottomInteractionView.backgroundColor = COLOR_CONRTOLVIEW;
    [self.videoControllView addSubview:self.bottomInteractionView];
    
    self.topInteractionView = [[UIView alloc]initWithFrame:CGRectZero];
    self.topInteractionView.backgroundColor = COLOR_CONRTOLVIEW;
    [self.videoControllView addSubview:self.topInteractionView];
#pragma mark--------以下可以自己定义UI 写完初始化 在updateFrame的方法里面添加约束 方便管理-----------------------
    //进度条
    self.sliderConrtoller = [[ZSliderView alloc]initWithFrame:CGRectZero isLive:self.isLive];
    self.sliderConrtoller.delegate = self;
    [self.bottomInteractionView addSubview:self.sliderConrtoller];
    

    //TODO
    
    //提示区域 等最终开始的时候在做 码率在研究中
    self.lableTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1300, 50)];
    self.lableTitle.text = @"这里都可以加东西 看需求做可以加东西 看需求做可以加东西 看需求做可以加东西 看需求做";
    self.lableTitle.textColor = [UIColor redColor];
    [self.topInteractionView addSubview:self.lableTitle];
    
    [self.videoControllView addSubview:self.clarityView];

    //切换码率的时候
    /*
      先记录一个时间点 有一个方法可以获取当前时间的图片,把这个图贴在这个view上 做一个假象.然后加载 完成以后跳转到这个时间点
     - (UIImage *)thumbnailImageAtCurrentTime;/这个方法 返回image
     思路有两种:1,给一个高清的视屏链接, 我在本地降低码率 使用最低的
     2,不同码率不同的视屏链接,我做好中间的衔接(衔接的时候按照上的步骤做)
     */
    
    //测试用 返回当前秒数的图
    /*
    self.imagecurrentImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.imagecurrentImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.videoControllView addSubview:self.imagecurrentImage];
     */
    
    
#pragma mark--------以上可以自己定义UI--------------------------------
    
}
//更新frame
- (void)updateFrameIsUpdata:(BOOL)isUpdate
{

    if (isUpdate)
    {
        [self.bottomInteractionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.videoControllView).offset(0);
            make.height.equalTo(@(self.type==ZInterfaceOrientationUp?HEIGHTSCANLE_BOTTOMVIEW:HEIGHTSCANLE_BOTTOMVIEW_SIX));
        }];
        
        [self.topInteractionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self).offset(0);
            make.height.equalTo(@(self.type==ZInterfaceOrientationUp?HEIGHTSCANLE_BOTTOMVIEW:HEIGHTSCANLE_BOTTOMVIEW_SIX));
        }];
    }
    else
    {
        [self.ZPlay.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self).offset(0);
        }];;
        [self.videoControllView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self).offset(0);
        }];
//底部-------todo
        [self.bottomInteractionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.videoControllView).offset(0);
         
            make.height.equalTo(@(self.type==ZInterfaceOrientationUp?HEIGHTSCANLE_BOTTOMVIEW:HEIGHTSCANLE_BOTTOMVIEW_SIX));
        }];
        
        [self.sliderConrtoller mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomInteractionView.mas_left).offset(0);
            make.right.equalTo(self.bottomInteractionView.mas_right).offset(0);
            make.top.bottom.equalTo(self.bottomInteractionView).offset(0);
            
        }];
        //上部-------
        [self.topInteractionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self).offset(0);
            make.height.equalTo(@(self.type==ZInterfaceOrientationUp?HEIGHTSCANLE_BOTTOMVIEW:HEIGHTSCANLE_BOTTOMVIEW_SIX));
        }];
        
        //test
        /*
         [self.imagecurrentImage mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self).offset(0);
         make.centerY.equalTo(self).offset(0);
         make.height.equalTo(@100);
         make.width.equalTo(@100);
         }];
         边上出来的东西例如清晰度
         [self.clarityView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.mas_right).offset(0);
         make.top.bottom.equalTo(self).offset(0);
         make.width.equalTo(@70);
         }];*/

    }
}

#pragma mark ---------监听一些ijk播放时候的状态
- (void)setUpVideoStateBack
{
    

    //读取状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    //播放完毕状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    //是否准备完毕
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaPlaybackIsPrepared:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];

    //播放中的各种状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    //屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    
}

- (void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)orientationChanged
{
    switch ([[UIDevice currentDevice]orientation])
    {
        case  UIDeviceOrientationPortrait:
            NSLog(@"home键在下");
            self.type = ZInterfaceOrientationUp;
            self.frame = self.oldFrame;
            break;
            
        case  UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"home键在上");
            self.type = ZInterfaceOrientationDown;
            break;
            
        case  UIDeviceOrientationLandscapeLeft:
            NSLog(@"home键在左");
            self.type = ZInterfaceOrientationLandscapeLeft;
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
            break;
            
        case  UIDeviceOrientationLandscapeRight:
            self.type =ZInterfaceOrientationLandscapeRight;
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            NSLog(@"home键在右");
            break;
            
        default:
            self.type = ZInterfaceOrientationUnknown;
            NSLog(@"不想知道");
            break;
    }
    
}


- (void)loadStateDidChange:(NSNotificationCenter *)notification
{
    NSLog(@"读取中");
    
}

- (void)moviePlayeBackDidFinish:(NSNotificationCenter *)notification
{
    NSLog(@"播放完");
    [self.playStateButton setImage:[UIImage imageNamed:@"play"] forState:(UIControlStateNormal)];//播放完成以后就这样

}

- (void)mediaPlaybackIsPrepared:(NSNotificationCenter *)notification
{
    NSLog(@"准备完毕");
    self.ZPlay.currentPlaybackTime =  _currentTimeForClarity;
    self.sliderConrtoller.sliderTotalTime = self.ZPlay.duration;
    self.sliderConrtoller.currentTime = self.ZPlay.currentPlaybackTime;
    [self  afterThreeSecondsHidden];
    
}

- (void)moviePlayerPlaybackStateDidChange:(NSNotificationCenter *)notification
{
    NSLog(@"%@",notification);
    [self.timer  fire];//开启计时器
    switch (self.ZPlay.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"停止");
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
        {   NSLog(@"播放");
            //todo
            self.sliderConrtoller.isMovingSlider = NO;//滑动继续
            _currentTimeForClarity = 0;//清空记录 继续
            [_cutImageView removeFromSuperview];//移除切图
        }
            break;
        
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"暂停");
            break;
        
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"中断");
            break;
        
        case IJKMPMoviePlaybackStateSeekingForward:
            NSLog(@"前进");
            break;
        
        case IJKMPMoviePlaybackStateSeekingBackward:
            NSLog(@"后退");
            break;

    }
}
- (void)updateEvent
{
    self.imagecurrentImage.image = [self.ZPlay thumbnailImageAtCurrentTime];
    self.sliderConrtoller.currentTime = self.ZPlay.currentPlaybackTime;
    self.sliderConrtoller.progressTime = self.ZPlay.playableDuration;
    [self.sliderConrtoller updateTime];
//    [self getInterfaceBytes];
}
#pragma mark -----进度条的界面

//滑动改变结束
- (void)sliderMovingEnd:(NSTimeInterval)currentTime
{
    self.ZPlay.currentPlaybackTime = currentTime;
    [self afterThreeSecondsHidden];
    if (_delegate &&[_delegate respondsToSelector:@selector(playCurrentTime:)])
    {
        [_delegate playCurrentTime:currentTime];
    }
}
//滑动改变
- (void)sliderValueChanged:(NSTimeInterval)changedTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];//在滑动的时候 取消消失
    if (_delegate &&[_delegate respondsToSelector:@selector(sliderValueChangedInPlayView:)])
    {
        [_delegate sliderValueChangedInPlayView:changedTime];
    }

}
//下一个
- (void)nextButtonClick:(UIButton *)button
{
    
    self.currentPlayUrl = [self.dataSource nextPlayUrl:self.currentPlayUrl];
    [self startWithPlayUrl:self.currentPlayUrl isLive:NO ];
    
}
//清晰度//todo
- (void)clarityButtonClick:(UIButton *)button
{
   /* [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.clarityView.frame;
        frame.origin.x =frame.origin.x - frame.size.width;
        self.clarityView.frame  = frame;
    }];*/
    
    self.cutImageView.image = [self.ZPlay thumbnailImageAtCurrentTime];
    _currentTimeForClarity = self.ZPlay.currentPlaybackTime;
    self.currentPlayUrl = [self.dataSource changeClarity];
    [self startWithPlayUrl:self.currentPlayUrl isLive:NO];
    [self.videoControllView insertSubview:self.cutImageView atIndex:0];
}
//播放暂停
//todo 这里有个小bug 需要来完善 ,就是暂停的时候定时器还是在计算
- (void)playButtonChanged:(UIButton *)button
{
    NSLog(@"%f",self.ZPlay.currentPlaybackTime);
    self.playStateButton = button;
    UIImage *image = nil;
    if (self.ZPlay.playbackState == IJKMPMoviePlaybackStatePlaying)
    {
        [self.ZPlay pause];
        image = [UIImage imageNamed:@"play"];
        
    }
    else if (self.ZPlay.playbackState == IJKMPMoviePlaybackStatePaused)
    {
        [self.ZPlay prepareToPlay];
        [self.ZPlay play];
        
        image = [UIImage imageNamed:@"pause"];
        
    }
    else
    {
        self.ZPlay.currentPlaybackTime = 0;
        [self.ZPlay play];
        image = [UIImage imageNamed:@"pause"];
    }
    
    [button setImage:image forState:(UIControlStateNormal)];
    //吧这个状态回调出去给控制器用 ,说不定可以暂停的时候放个广告啊什么的
    if (_delegate&&[_delegate respondsToSelector:@selector(playStateChanged:)])
    {
        [_delegate playStateChanged:self.ZPlay.playbackState];
    }
    
}
//全屏幕方法
- (void)fullScreenButtonChanged:(UIButton *)button
{
    self.fullScreenButton = button;
    
    if (self.type == ZInterfaceOrientationUp)
    {
        [UIView animateWithDuration:0.25 animations:^{
            NSNumber * value  = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        }completion:^(BOOL finished) {
            CGRect playerFrame = self.frame;
            playerFrame.size.width = [UIScreen mainScreen].bounds.size.width;
            playerFrame.size.height = [UIScreen mainScreen].bounds.size.height;
            self.frame = playerFrame;
            [self updateFrameIsUpdata:YES];
           
        }];
        self.type = ZInterfaceOrientationLandscapeLeft;
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            NSNumber * value  = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            self.frame = self.oldFrame;
            [self updateFrameIsUpdata:YES];
            
        }];
        self.type = ZInterfaceOrientationUp;
    }
    
    if (_delegate &&[_delegate respondsToSelector:@selector(fullScreen)])
    {
        [_delegate fullScreen];
    }
    
}




#pragma mark ------touchView的代理------------------
- (void)moveOffsetforSeconds:(NSTimeInterval)seconds
{
    self.ZPlay.currentPlaybackTime +=  seconds;
    if (_delegate &&[_delegate respondsToSelector:@selector(slidingScreenChangeTime:piayer:)])
    {
        [_delegate slidingScreenChangeTime:seconds piayer:self.ZPlay];
    }
}

- (void)changeVlumeValue:(CGFloat)value currentValue:(CGFloat)currentValue
{
    NSLog(@"vlume:%f",value);
    NSLog(@"current:%f",currentValue);
}
- (void)changeBrightnessValue:(CGFloat)value currentValue:(CGFloat)currentValue
{

    NSLog(@"changeBrightnessValue:%f",value);
    NSLog(@"current:%f",currentValue);
}
- (void)touchTheView:(TouchNumberForType)type
{
    if(type == TouchNumberForTypeClick)
    {//单击
        [self topViewAndBottomViewHiddenOrNO];
        _isTopAndBottomHidden =!_isTopAndBottomHidden;
        _isTopAndBottomHidden?nil:[NSObject cancelPreviousPerformRequestsWithTarget:self];
        _isTopAndBottomHidden?nil:[self afterThreeSecondsHidden];
        
        if (_delegate && [_delegate respondsToSelector:@selector(oneClick)])
        {
            [_delegate oneClick];
        }
    }
    else if (type == TouchNumberForTypeDoubleclick)
    {//双击
        [self playButtonChanged:self.playStateButton];
        if (_delegate && [_delegate respondsToSelector:@selector(doubleClick)])
        {
            [_delegate doubleClick];
        }
    }
}
#pragma mark 一些播放器的操作

- (void)play
{
    [self.ZPlay play];
}

- (void)pause
{
    [self.ZPlay pause];
}

- (void)stop
{
    [self.ZPlay stop];
}
#pragma mark------本类的一些操作--------
//3秒以后消失
- (void)afterThreeSecondsHidden
{
    [self performSelector:@selector(topViewAndBottomViewHidden) withObject:nil afterDelay:8];
    
}
//自动调用的专用消失
- (void)topViewAndBottomViewHidden
{
    
    self.topInteractionView.alpha =  0;
    self.bottomInteractionView.alpha = 0;
    _isTopAndBottomHidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.clarityView.frame;
        frame.origin.x = self.frame.size.width;
        self.clarityView.frame  = frame;
    }];
    
}
//自动消失的topview和botmveiw
- (void)topViewAndBottomViewHiddenOrNO
{
    self.topInteractionView.alpha = _isTopAndBottomHidden? 1: 0;
    self.bottomInteractionView.alpha = _isTopAndBottomHidden?1:0 ;
}
//释放掉这个播放器
- (void)removePlayer
{
   //定时器关掉
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    if (self.ZPlay)
    {
        [self.ZPlay shutdown];
        self.ZPlay = nil;
    }
    
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    
    
    
}
//判断当前方向
- (ZInterfaceOrientationType)currentDirectionEquipment
{
    [self orientationChanged];
    return self.type;
}
//清晰度view//todo
- (UIView *)clarityView
{
    if (!_clarityView)
    {
        _clarityView = [[UIView alloc]initWithFrame:CGRectZero];
        _clarityView.backgroundColor = COLOR_CONRTOLVIEW;
    }
    return _clarityView;
}
//切图
- (UIImageView *)cutImageView
{
    if (!_cutImageView)
    {
        _cutImageView = [[UIImageView alloc]initWithFrame:self.frame];

    }
    return _cutImageView;
}
@end

