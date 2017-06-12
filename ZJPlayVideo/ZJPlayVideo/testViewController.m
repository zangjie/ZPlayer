//
//  TestViewController.m
//  ZJPlayVideo
//
//  Created by zj on 17/6/6.
//  Copyright © 2017年 zj. All rights reserved.
//

#import "TestViewController.h"
#import "PlayViewController.h"
@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 200, 100, 100);
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];

}
-(void)buttonAction:(UIButton*)sender{
    
    [self.navigationController pushViewController:[[PlayViewController alloc]init] animated:YES];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
