//
//  ZTouchMoveView.m
//  ZJPlayVideo
//
//  Created by zj on 17/6/4.
//  Copyright © 2017年 zj. All rights reserved.
//

#import "ZTouchMoveView.h"
#import<MediaPlayer/MediaPlayer.h>
typedef NS_ENUM(NSInteger, ZVideoMoveType) {
    ZVideoMoveTypeNone                 = 0,//未判断状态的时候
    ZVideoMoveTypeMoveBack             = 1,//前进后退
    ZVideoMoveTypeMoveVolume           = 2,//音量
    ZVideoMoveTypeMoveBrightness       = 3,//亮度
};
@interface ZTouchMoveView ()
/*
 音量view
 */
@property (nonatomic, strong)MPVolumeView *volumeView;
/*
 控制音量
 */
 @property (strong, nonatomic) UISlider* volumeViewSlider;


@end

@implementation ZTouchMoveView
{

    CGPoint _oldPoint;//记录之前的偏移量
    CGFloat _totalOffset;//偏移总量
    CGFloat _totalOffsetY;//Y偏移总量
    CGFloat _totalOffsetX;//X偏移总量

    ZVideoMoveType _type;//类型

}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%f",_totalOffset);

    if (_type == ZVideoMoveTypeNone)
    {//范围内没触发效果,算单击和双击
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        
        if (touch.tapCount == 1)
        {
            [self performSelector:@selector(clickSingleTap:) withObject:[NSValue valueWithCGPoint:touchPoint] afterDelay:0.3];
        }
        else if (touch.tapCount == 2)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self clickDoubleTap:[NSValue valueWithCGPoint:touchPoint]];
        }
    }
    if (_type == ZVideoMoveTypeMoveBack)
    {//快进快退
        if (_delegate && [_delegate respondsToSelector:@selector(moveOffsetforSeconds:)])
        {
            [_delegate moveOffsetforSeconds:_totalOffset];
        }
    }
    [self clearOffset];
  
}
- (void)clickSingleTap:(NSValue*)pointValue
{
    if (_delegate &&[_delegate respondsToSelector:@selector(touchTheView:)])
    {
        [_delegate touchTheView:TouchNumberForTypeClick];
    }
}

- (void)clickDoubleTap:(NSValue*)pointValue
{
    if (_delegate &&[_delegate respondsToSelector:@selector(touchTheView:)])
    {
        [_delegate touchTheView:TouchNumberForTypeDoubleclick];
    }
}

/*
 主要用这个来实现屏幕调节和音量调节 用pan手势在zplayview上可能会冲突,要加别的手势
 思路:音量和亮度  快进快退可能冲突, 那就判断 谁的偏移量超过30,那就执行,其他的不执行
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    _type = [self operationTypes:currentP];
    [self moveingChangeVideoProgress];
    _totalOffsetY = _totalOffsetY+(_oldPoint.y?(currentP.y-_oldPoint.y):0);
    _totalOffsetX = _totalOffsetX+(_oldPoint.x?(currentP.x-_oldPoint.x):0);
    if (_type == ZVideoMoveTypeMoveBack){
        [self moveingChangeVideoProgress];
    }
    else if (_type == ZVideoMoveTypeMoveVolume) {//改变音量和亮度是及时的 所以在movde中写,进度是在end中写
        [self changVolumeValue:(_oldPoint.y?(currentP.y-_oldPoint.y):0)];
        
    }
    else if (_type == ZVideoMoveTypeMoveBrightness) {
        [self changeScreenBrightness:(_oldPoint.y?(currentP.y-_oldPoint.y):0)];
    }

        
        
        _oldPoint = currentP;

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

}
//判断操作类型
- (ZVideoMoveType)operationTypes:(CGPoint)point{

    if(_type != ZVideoMoveTypeNone){
        return _type;
    }
    if(fabsf(_totalOffsetX) > 10){
        return ZVideoMoveTypeMoveBack;
    }
    if(fabsf(_totalOffsetY) > 10){
        if(point.x < self.frame.size.width/3){
            return ZVideoMoveTypeMoveVolume;//左边音量
        }
        else if (point.x > self.frame.size.width/3*2) {
            return ZVideoMoveTypeMoveBrightness;//亮度
        }
       
    }
    return ZVideoMoveTypeNone;

}
//快进快退的方法/屏幕宽度定制为1分钟(60s),移动距离来改变视屏快进快退的时间
- (void)moveingChangeVideoProgress{
    int timeOffset = self.frame.size.width/60;//1秒对应的偏移量 用int取整数
    CGFloat progressOffset =  _totalOffsetX/timeOffset;
    _totalOffset = progressOffset;
   
}
//清楚记录
- (void)clearOffset{
    //便宜结束以后吧记录移除
    _oldPoint = CGPointZero;
    _totalOffset = 0;
    _totalOffsetY = 0;
    _totalOffsetX = 0;
    _type = ZVideoMoveTypeNone;
}

//音量
- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

//改变音量
- (void)changVolumeValue:(CGFloat)value {
    CGFloat volumeValue = - 1/self.frame.size.height;
    self.volumeView.frame = CGRectMake(1000, 1000, 10, 10);
    [self.volumeViewSlider setValue:self.volumeViewSlider.value+volumeValue*value animated:YES];
    if(_delegate && [_delegate respondsToSelector:@selector(changeVlumeValue:currentValue:)]){
        [_delegate changeVlumeValue:volumeValue*value currentValue:self.volumeViewSlider.value];
    }

}
- (void)changeScreenBrightness:(CGFloat)value{
    CGFloat brightnessValue = - 1/self.frame.size.height;
    [[UIScreen mainScreen] setBrightness:[UIScreen mainScreen].brightness +brightnessValue*value];
    if(_delegate && [_delegate respondsToSelector:@selector(changeBrightnessValue:currentValue:)]){
        [_delegate changeBrightnessValue:brightnessValue*value currentValue:[UIScreen mainScreen].brightness];
    }
}

@end
