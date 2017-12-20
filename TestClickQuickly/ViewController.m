//
//  ViewController.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//  Copyright © 2017年 dj226. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 80, 80)];
    button.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(nextVC) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"viewDidLoad ");
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchDo)];
//    [tapgesture addTarget:self action:@selector(onTouchDoTwo:)];
    [self.view addGestureRecognizer:tapgesture];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
    view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view];
    UITapGestureRecognizer *tapgesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchWithoutParam)];
    [view addGestureRecognizer:tapgesture1];
    
}

- (void)onTouchDoTwo:(UIGestureRecognizer *)recognizer
{
    NSLog(@"onTouchDoTwo");
}

- (void)onTouchDo
{
    NSLog(@"tap view");
}

- (void)onTouchWithoutParam
{
    NSLog(@"tap subview");
}

- (void)nextVC
{
    NSLog(@"push");
    [self.navigationController pushViewController:[ViewController new] animated:YES];
    NSLog(@"after push");
}

//慢速点击：
//2017-09-25 21:07:55.072 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:55.201 TestClickQuickly[96730:3606493] push
//2017-09-25 21:07:55.202 TestClickQuickly[96730:3606493] after push
//2017-09-25 21:07:55.203 TestClickQuickly[96730:3606493] viewDidLoad
//2017-09-25 21:07:55.203 TestClickQuickly[96730:3606493] willShowViewController
//2017-09-25 21:07:55.208 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:55.208 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:55.558 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:55.561 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:55.708 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:55.708 TestClickQuickly[96730:3606493] didShowViewController
//2017-09-25 21:07:55.709 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:56.062 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:56.062 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:56.063 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:08:00.001 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:09:00.001 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 14:10:00.001 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 14:11:00.001 TestClickQuickly[96730:3606493] activity:32

//快速点击：
//2017-09-25 21:06:07.979 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.012 TestClickQuickly[96730:3606493] push
//2017-09-25 21:06:08.013 TestClickQuickly[96730:3606493] after push
//2017-09-25 21:06:08.014 TestClickQuickly[96730:3606493] push
//2017-09-25 21:06:08.015 TestClickQuickly[96730:3606493] after push
//2017-09-25 21:06:08.015 TestClickQuickly[96730:3606493] viewDidLoad
//2017-09-25 21:06:08.016 TestClickQuickly[96730:3606493] willShowViewController
//2017-09-25 21:06:08.019 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.019 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.027 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.368 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.369 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.519 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.519 TestClickQuickly[96730:3606493] didShowViewController
//2017-09-25 21:06:08.521 TestClickQuickly[96730:3606493] viewDidLoad
//2017-09-25 21:06:08.521 TestClickQuickly[96730:3606493] willShowViewController
//2017-09-25 21:06:08.526 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.526 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.876 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:08.878 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:09.026 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:09.027 TestClickQuickly[96730:3606493] didShowViewController
//2017-09-25 21:06:09.027 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:09.378 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:09.378 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:06:09.379 TestClickQuickly[96730:3606493] activity:32
//2017-09-25 21:07:00.001 TestClickQuickly[96730:3606493] activity:32

@end
