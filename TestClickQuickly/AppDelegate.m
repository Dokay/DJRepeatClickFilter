//
//  AppDelegate.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//  Copyright © 2017年 dj226. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UIView+DJRepeatClickFilter.h"

//BOOL DJRepeatClickFilterEnable = YES;

@interface AppDelegate ()<UINavigationControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    nav.delegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [UIView setOtherFilter:^BOOL{
       //other conditions you want to filter
        return YES;
    }];
    
    //Do Test
    [AppDelegate hd_repeat_registRunloopObserver];
    
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"willShowViewController");
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"didShowViewController");
}

+ (void)hd_repeat_registRunloopObserver
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFStringRef runLoopMode = kCFRunLoopCommonModes;
    
    void (^runLoopObserverCallback)(CFRunLoopObserverRef runLoopObserver, CFRunLoopActivity activity) = ^(CFRunLoopObserverRef runLoopObserver, CFRunLoopActivity activity){
        NSLog(@"activity:%ld",activity);
    };
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                                       kCFRunLoopBeforeWaiting|kCFRunLoopExit,
                                                                       true,
                                                                       INT_MAX-1,
                                                                       runLoopObserverCallback);
    CFRunLoopAddObserver(runLoop, observer, runLoopMode);
    CFRelease(observer);
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
