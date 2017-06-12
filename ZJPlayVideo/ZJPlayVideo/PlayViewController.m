//
//  ViewController.m
//  ZJPlayVideo
//
//  Created by zj on 16/11/17.
//  Copyright © 2016年 zj. All rights reserved.
//

#import "PlayViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZPlayView.h"
#import "ZTouchMoveView.h"
#import <Masonry.h>
#import <SVProgressHUD.h>
#define playurl @"http://fastwebcache.yod.cn/yanglan/2013suoluosi/2013suoluosi_850/2013suoluosi_850.m3u8"
#define liveURL @"rtmp://live.hkstv.hk.lxdns.com/live/hks"
@interface PlayViewController ()<ZPlayViewDelegate,ZPlayViewChangeClarityDataSoure>

/**
 *  声明播放视频的控件属性[既可以播放视频也可以播放音频]
 */
@property (nonatomic,strong) ZPlayView *playView;
@property (nonatomic, strong)NSArray *playListArray;
@end

@implementation PlayViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.playView removePlayer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationController.navigationBar.hidden = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 200, 100, 100);
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"网络视屏" forState:(UIControlStateNormal)];
    [self.view addSubview:button];
//切换视频
    UIButton *buttonLive = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonLive.frame = CGRectMake(100, 300, 100, 100);
    buttonLive.backgroundColor = [UIColor blackColor];
    [buttonLive addTarget:self action:@selector(buttonAction1:) forControlEvents:(UIControlEventTouchUpInside)];
    [buttonLive setTitle:@"直播" forState:(UIControlStateNormal)];

    [self.view addSubview:buttonLive];
    
}
//测试切换用的
-(void)buttonAction:(UIButton*)sender{
    
    [self.playView startWithPlayUrl:self.playListArray[0] isLive:NO ];
    
    
    
}

-(void)buttonAction1:(UIButton *)sender{
    [self.playView startWithPlayUrl:liveURL isLive:YES ];
    
    
}

#pragma mark -------datasource----------------------------------------------------------------------------

//切换清晰度
- (NSString *)changeClarity{

    return @"http://ac-2hkfpDHJ.clouddn.com/63cbedb764828e197fb5.mp4";

}
//下一集回调
- (NSString *)nextPlayUrl:(NSString *)currentPlayURL{    //判断是否是全屏
    
   NSUInteger index = [self.playListArray indexOfObject:currentPlayURL];
   if(self.playListArray.count-1 > index+1 || self.playListArray.count-1 == index+1){
       index += 1;
   }else{
       index = 0;
   }
    return self.playListArray[index];
}

#pragma mark -------delegate------------------------------------------------------------------------------

//播放状态的回调
- (void)playStateChanged:(IJKMPMoviePlaybackState)state{

    if (state == IJKMPMoviePlaybackStatePlaying) {
        NSLog(@"在播放");
    }
    else if(state == IJKMPMoviePlaybackStatePaused){
    
        NSLog(@"暂停了");
    }
}
//全屏幕
- (void)fullScreen{
    NSLog(@"全屏or小屏");

}

//时间改变的回调
- (void)slidingScreenChangeTime:(NSTimeInterval)changedTime piayer:(IJKFFMoviePlayerController *)player{

    NSLog(@"%f",changedTime);
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"快进或者快退%f",changedTime]];

    
}
//滑块区域的回调
- (void)playCurrentTime:(NSTimeInterval)time{
    NSLog(@"%f",time);
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"当前时间%f",time]];

}
- (void)sliderValueChangedInPlayView:(NSTimeInterval)changedTime{
    NSString *minute = [NSString stringWithFormat:@"%02f",changedTime/60];
//    NSString *second = [NSString stringWithFormat:@"%02f",changedTime%60];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",minute]];


}
//单击回调
- (void)oneClick{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"消失或者出现"]];

}
//双击回调
-(void)doubleClick{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"暂停或者播放"]];
    NSLog(@"暂停");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
