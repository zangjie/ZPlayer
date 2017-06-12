//
//  ZSliderView.m
//  ZJPlayVideo
//
//  Created by zj on 17/6/1.
//  Copyright © 2017年 zj. All rights reserved.
//

#define WIDTHSCANLE_SLIDERVIEW  10
#define KScreenW [UIScreen mainScreen].bounds.size.width
#define COLOR_SLIDER [UIColor colorWithRed:252/255.0 green:98/255.0 blue:147/255.0 alpha:1]
#define COLOR_PROGRESS [UIColor colorWithRed:252/255.0 green:126/255.0 blue:167/255.0 alpha:0.5]

#import "ZSliderView.h"
#import <Masonry.h>
@interface ZSliderView ()
/*
 总时间lable
 */
@property (nonatomic, strong)UILabel *totleTimeLable;
/*
 当前时间lable
 */
@property (nonatomic, strong)UILabel *currentTimeLable;

/*
 缓冲进度
 */
@property (nonatomic, strong) CALayer *progresslayer;
/*
点击移动滑块的手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *tap;
/*
 播放/暂停
 */
@property (nonatomic, strong) UIButton *playStateButton;
/*
 全屏按钮
 */
@property (nonatomic, strong) UIButton *fullScreenButton;
/*
 下一集
 */
@property (nonatomic, strong) UIButton *nextButton;
/*
 清晰度
 */
@property (nonatomic, strong) UIButton *buttonClarity;

@end

@implementation ZSliderView

- (instancetype)initWithFrame:(CGRect)frame isLive:(BOOL)islive
{
    
    if (self = [super initWithFrame:frame])
    {
        self.isLive = islive;
        [self setUpUI];
        [self setUpPreference];
        [self updateFrame];
    }
    return self;
}


- (void)setUpUI
{
    self.progressView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.progresslayer = self.isLive? nil:[CALayer layer];
    self.progresslayer.frame = self.isLive?CGRectZero:CGRectMake(0, 0, 0, 5);
    self.sliderView = [[ZSlider alloc]initWithFrame:CGRectZero];
    self.totleTimeLable = [[UILabel alloc]initWithFrame:CGRectZero];
    self.currentTimeLable = [[UILabel alloc]initWithFrame:CGRectZero];
    self.playStateButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.fullScreenButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.nextButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonClarity = [UIButton buttonWithType:(UIButtonTypeCustom)];
    
   
    
    [self addSubview:self.progressView];
    [self addSubview:self.sliderView];
    [self addSubview:self.totleTimeLable];
    [self addSubview:self.currentTimeLable];
    [self addSubview:self.fullScreenButton];
    [self addSubview:self.playStateButton];
    [self addSubview:self.nextButton];
    [self addSubview:self.buttonClarity];

    
    [self.progressView.layer addSublayer:self.progresslayer];

}
- (void)updateFrame
{
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.height.equalTo(@5);
        make.top.equalTo(self).offset(-2.5);
        
    }];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.top.equalTo(self).offset(-15);
        make.height.equalTo(@30);
    }];
   
    [self.playStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(WIDTHSCANLE_SLIDERVIEW);
        make.top.equalTo(self.sliderView.mas_bottom).offset(0);
        make.bottom.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.width.mas_equalTo(self.playStateButton.mas_height).multipliedBy(1);
    }];
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.top.equalTo(self.sliderView.mas_bottom).offset(0);
        make.bottom.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.width.mas_equalTo(self.fullScreenButton.mas_height).multipliedBy(1);
    }];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playStateButton.mas_right).offset(WIDTHSCANLE_SLIDERVIEW);
        make.top.equalTo(self.sliderView.mas_bottom).offset(0);
        make.bottom.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.width.mas_equalTo(self.nextButton.mas_height).multipliedBy(1);
    }];
    
    [self.currentTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextButton.mas_right).offset(WIDTHSCANLE_SLIDERVIEW);
        make.top.equalTo(self.sliderView.mas_bottom).offset(0);
        make.bottom.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.width.mas_equalTo(self.currentTimeLable.mas_height).multipliedBy(1.5);
    }];
    [self.totleTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLable.mas_right).offset(0);
        make.top.equalTo(self.sliderView.mas_bottom).offset(0);
        make.bottom.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.width.mas_equalTo(self.totleTimeLable.mas_height).multipliedBy(1.5);
        
    }];
    [self.buttonClarity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullScreenButton.mas_left).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.top.equalTo(self.sliderView.mas_bottom).offset(0);
        make.bottom.equalTo(self).offset(-WIDTHSCANLE_SLIDERVIEW);
        make.width.mas_equalTo(self.fullScreenButton.mas_height).multipliedBy(1);
        
    }];


}

- (void)setUpPreference
{
    //缓冲进度
    self.progressView.backgroundColor = self.progressColorl?self.progressColorl:[UIColor lightGrayColor];
    //缓冲
    self.progresslayer.backgroundColor = self.progressColorl?self.progressColorl.CGColor:COLOR_PROGRESS.CGColor;
    
    //给进度条添加点击手势来跳转
    self.sliderView.maximumTrackTintColor = [UIColor clearColor];
    self.sliderView.minimumTrackTintColor = self.sliderColor?self.sliderColor:COLOR_SLIDER;
    [self.sliderView addTarget:self action:@selector(sliderChanging:) forControlEvents:(UIControlEventValueChanged)];//滑动改变
    [self.sliderView addTarget:self action:@selector(sliderDidChanged:) forControlEvents:(UIControlEventTouchUpInside)];//滑动松开
    [self.sliderView addTarget:self action:@selector(sliderTouchDown:) forControlEvents:(UIControlEventTouchDown)];
    [self.sliderView setThumbImage:[UIImage imageNamed:@"sliderImage"] forState:(UIControlStateNormal)];
    
    
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderTapAction:)];
    [self.sliderView addGestureRecognizer:self.tap];
    //总时间
    self.totleTimeLable.textColor = [UIColor whiteColor];
    self.totleTimeLable.adjustsFontSizeToFitWidth= YES;

    self.totleTimeLable.textAlignment = NSTextAlignmentCenter;
    self.totleTimeLable.text = @"丨--:--";
    //当前时间
    self.currentTimeLable.textColor = [UIColor whiteColor];
    self.currentTimeLable.adjustsFontSizeToFitWidth= YES;
    self.currentTimeLable.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLable.text = @"--:--";
    //下一曲 播放 全屏 清晰度
    
    self.nextButton.frame = CGRectZero;
    [self.nextButton setImage:[UIImage imageNamed:@"next"] forState:(UIControlStateNormal)];
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.playStateButton.frame = CGRectZero;
    [self.playStateButton setImage:[UIImage imageNamed:@"pause"] forState:(UIControlStateNormal)];
    self.playStateButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.playStateButton addTarget:self action:@selector(changePlayStateAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.fullScreenButton.frame = CGRectZero;
    [self.fullScreenButton setImage:[UIImage imageNamed:@"big"] forState:(UIControlStateNormal)];
    self.fullScreenButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.buttonClarity addTarget:self action:@selector(clarityButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.buttonClarity setTitle:@"标" forState:(UIControlStateNormal)];
}
- (void)updateTime
{
    if (self.isLive)
    {
        self.sliderView.alpha= 0;
        self.progressView.alpha= 0;
    }
    else
    {
        self.sliderView.alpha= 1;
        self.progressView.alpha= 1;
        self.currentTimeLable.text = [NSString stringWithFormat:@"%@",[self TimeformatFromSeconds:self.currentTime]];
        self.totleTimeLable.text = [NSString stringWithFormat:@"丨%@",[self TimeformatFromSeconds:self.sliderTotalTime]];
        if (self.sliderTotalTime)
        {
            self.progresslayer.frame = CGRectMake(0, 0,(self.progressTime/self.sliderTotalTime) * self.frame.size.width,5);
            self.isMovingSlider ? nil : [self.sliderView setValue:self.currentTime/self.sliderTotalTime animated:YES];
        }
    }
}
//下一曲
- (void)nextButtonAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(nextButtonClick:)])
    {
        [_delegate nextButtonClick:sender];
    }
}
//播放暂停
- (void)changePlayStateAction:(UIButton *)sender
{
    
    if (_delegate &&[_delegate respondsToSelector:@selector(playButtonChanged:)])
    {
        [_delegate playButtonChanged:sender];
    }
    
}
//全屏
- (void)fullScreenAction:(UIButton *)sender
{
    if (_delegate &&[_delegate respondsToSelector:@selector(fullScreenButtonChanged:)])
    {
        [_delegate fullScreenButtonChanged:sender];
    }
    
}
//清晰度
- (void)clarityButtonAction:(UIButton *)sender
{
    
    if (_delegate &&[_delegate respondsToSelector:@selector(clarityButtonClick:)])
    {
        [_delegate clarityButtonClick:sender];
    }
}


//滑块在变化的时候关闭这个自动变换的值
- (void)sliderChanging:(UISlider *)slider
{
    self.isMovingSlider = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(sliderValueChanged:)])
    {
        [_delegate sliderValueChanged:self.sliderView.value*self.sliderTotalTime];
    }
}
//滑块结束滑动的时候给这个视屏跳转
- (void)sliderDidChanged:(UISlider *)slider
{
    self.isMovingSlider = YES;
    self.tap.enabled = YES;

    [self.sliderView setValue:slider.value animated:YES];
    if (_delegate&&[_delegate respondsToSelector:@selector(sliderMovingEnd:)])
    {
        [_delegate sliderMovingEnd:slider.value*self.sliderTotalTime];
    }
}
//手在滑块上的时候关闭tap手势
- (void)sliderTouchDown:(UISlider *)slider
{
    self.tap.enabled = NO;
    
}
//点击进度条跳转不是滑动
- (void)sliderTapAction:(UITapGestureRecognizer *)tap
{
    self.isMovingSlider = YES;
    CGPoint point = [tap locationInView:self.sliderView];
    [self.sliderView setValue:point.x/self.sliderView.frame.size.width animated:YES];
    if (_delegate&&[_delegate respondsToSelector:@selector(sliderMovingEnd:)])
    {
        [_delegate sliderMovingEnd:self.sliderView.value*self.sliderTotalTime];
    }

}
#pragma mark -------- 把时间转换成为时分秒
- (NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    NSString *minute = [NSString stringWithFormat:@"%02ld",seconds/60];
    NSString *second = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *time = [NSString stringWithFormat:@"%@:%@",minute,second];
    return time;
}



@end
