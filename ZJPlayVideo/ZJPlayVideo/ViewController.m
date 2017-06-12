//
//  ViewController.m
//  wifiSocket
//
//  Created by zj on 2017/6/8.
//  Copyright © 2017年 zj. All rights reserved.
//


#import "ViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreFoundation/CoreFoundation.h>

#import <ifaddrs.h>
#import <arpa/inet.h>

#import <GCDAsyncSocket.h>
#import <GCDAsyncUdpSocket.h>

#import "ZPlayView.h"

@interface ViewController () <GCDAsyncSocketDelegate,ZPlayViewDelegate,ZPlayViewChangeClarityDataSoure,GCDAsyncUdpSocketDelegate>{

    int i;
}
// 1. 用于监听的socket
@property (nonatomic,strong) GCDAsyncSocket *listenSocket;
// 用于存放数据交互的socket
@property (nonatomic,strong) NSMutableArray *connectedSockets;
@property (nonatomic,strong) NSArray *picarray;
@property (nonatomic,strong) UIImageView *imageViewPic;

@property (nonatomic,strong) ZPlayView *playView;
@property (nonatomic, strong)NSArray *playListArray;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.navigationBar.hidden= YES;
    
    self.picarray = @[@"1.jpeg",@"2.jpeg",@"3.jpeg",@"4.jpeg",@"5.jpeg"];
    self.imageViewPic = [[UIImageView alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    self.imageViewPic.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewPic.image = [UIImage imageNamed:self.picarray[0]];
    [self.view addSubview:self.imageViewPic];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button addTarget:self action:@selector(buttonsen) forControlEvents:(UIControlEventTouchUpInside)];
    
    button.frame = CGRectMake(0, 500, 100, 100);
    [button setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [button setTitle:@"开启服务器" forState:(UIControlStateNormal)];
    [self.view addSubview:button];
    i= 0;
    self.playListArray = [NSArray arrayWithObjects:@"http://ac-2hkfpDHJ.clouddn.com/dd67223d488cb2153142.mp4",@"http://ips.ifeng.com/3gs.ifeng.com/userfiles/video02/2014/08/26/2220447-280-068-2354.mp4",@"http://baobab.wdjcdn.com/14463059939521445330477778425364388_x264.mp4",@"http://ac-2hkfpDHJ.clouddn.com/dd67223d488cb2153142.mp4",@"http://ips.ifeng.com/3gs.ifeng.com/userfiles/video02/2014/08/26/2220447-280-068-2354.mp4", nil];
    //切换直播
    
    
    [self.playView removePlayer];
    self.playView = [[ZPlayView alloc]initWithFrame:CGRectMake(0, 0 ,self.view.bounds.size.width,210)];
    //[self.playView startWithPlayUrl:self.playListArray[0] isLive:NO ];
    self.playView.dataSource= self;
    self.playView.delegate = self;
    [self.view addSubview:self.playView];

    
    //UPD接口
    GCDAsyncUdpSocket *udpsocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [udpsocket bindToPort:8888 error:&error];
    if(error){
        NSLog(@"%@",error);
    }
    else{
        [udpsocket beginReceiving:&error];
    
    }
    
    
}


#pragma mark-------------upd获得ip地址 匹配


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送信息成功");
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{

    NSLog(@"发送失败");
}
//接受到来自那边的请求同时把地址给过去 在吧自己的服务打开
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *stringArray = [string componentsSeparatedByString:@"**"];
    
        if([stringArray[0] isEqualToString:@"kongzhiTV"]){
            NSString *data = [self getIPAddress];
            [sock sendData:[data dataUsingEncoding:NSUTF8StringEncoding] toHost:stringArray[1] port:8888 withTimeout:-1 tag:0];
            [self buttonsen];

        }
    NSLog(@"接收到信息%@",string);

}

//开启服务器
- (void)buttonsen{
    
    BOOL issuccess = [self.listenSocket acceptOnInterface:[self getIPAddress] port:8888 error:nil];
    if(issuccess){
        NSLog(@"开启成功");
    }
    else {
        NSLog(@"开启失败");
    }
    

}


#pragma mark --  GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    [self.connectedSockets addObject:newSocket];//抢引用 不然会把链接关闭
    NSLog(@"接受到来自%@的连接",newSocket.connectedHost);
    //发送数据
    NSString *string = @"欢迎连接我的服务器";
    //-1代表永不超时
    [newSocket writeData:[string dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //只接收一次
    [newSocket readDataWithTimeout:-1 tag:0];
    
    // 4.2 接收数据  定时器 轮循,一直来接收数据
//     [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readData:) userInfo:newSocket repeats:YES];
//    
//    // 子线程的消息循环默认不会开启,需要手动开启
//     [[NSRunLoop currentRunLoop] run];
    
    //定时器的方式接收数据缺点:1s执行一次,并不实时,受设置的计时约束,另外如果没有新数据也在调用

    

}

//发送数据
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"已经发送完成");
}
//已经接受到
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{


    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    i++;
    if(i<self.picarray.count-1){
    }else{
        i=0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageViewPic.image=[UIImage imageNamed:self.picarray[i]];
        [self.playView startWithPlayUrl:self.playListArray[i] isLive:NO ];

    });

    //接收数据
    [sock readDataWithTimeout:-1 tag:0];
    //转发给其他用户
    for (GCDAsyncSocket *connectsocket in self.connectedSockets){
        if(connectsocket != sock){
            [connectsocket writeData:data withTimeout:-1 tag:0];
        }
    }
    
    
}
-(void)readData:(NSTimer *)timer{
    
    // 接收数据
    [timer.userInfo readDataWithTimeout:-1 tag:0];
    
}
// 用于监听的socket
- (GCDAsyncSocket *)listenSocket{
    
    if (_listenSocket == nil) {
        
        /*
         delegateQueue:时效性选择主线程,性能更好选择异步线程
         socketQueue:  执行连接,接受再去队列中执行,设置NULL会自动设置队列,使用自己的队列容易出现线程问题
         */
        
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0) socketQueue:NULL];
        
    }
    return _listenSocket;
}

// 用于存放数据交互的socket
- (NSMutableArray *)connectedSockets{
    
    if (_connectedSockets == nil) {
        _connectedSockets = [NSMutableArray array];
    }
    return _connectedSockets;
}


//#pragma mark -
//#pragma mark RHSocketConnection method
//
//- (void)openConnection
//{
//    [self closeConnection];
//    _connection = [[RHSocketConnection alloc] init];
//    
//    [_connection connectWithHost:_serverHost port:_serverPort];
//}
//
//- (void)closeConnection
//{
//    if (_connection) {
//        _connection.delegate = nil;
//        [_connection disconnect];
//        _connection = nil;
//    }
//}
//
//#pragma mark -
//#pragma mark RHSocketConnectionDelegate method
//
//- (void)didDisconnectWithError:(NSError *)error
//{
//    RHSocketLog(@"didDisconnectWithError...");
//}
//
//- (void)didConnectToHost:(NSString *)host port:(UInt16)port
//{
//    RHSocketLog(@"didConnectToHost...");
//}
//
//- (void)didReceiveData:(NSData *)data tag:(long)tag
//{
//    RHSocketLog(@"didReceiveData...");
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////获取wifi内容
//- (void)getwifi{
//    NSString *wifiName = @"没找到";
//    CFArrayRef myArray = CNCopySupportedInterfaces();
//    if(myArray != nil){
//        
//        CFDictionaryRef myDic = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
//        if(myDic != nil){
//            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDic);
//            wifiName = [dict valueForKey:@"SSID"];
//            NSLog(@"%@",dict);
//        }
//        
//        NSLog(@"wifiName:%@", wifiName);
//    }
//    NSLog(@"%@",[self getIPAddress]);
//    
//
//
//}
//
////获取ip
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
        freeifaddrs(interfaces);
        return address;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
