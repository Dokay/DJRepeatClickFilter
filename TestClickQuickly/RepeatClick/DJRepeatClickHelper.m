//
//  DJRepeatClickHelper.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//

#import "DJRepeatClickHelper.h"

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static BOOL bCanTap = NO;
static DJRepeatClickOtherFilterBlock _otherRepeatClickFilter;

@implementation DJRepeatClickHelper

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (dj_repeat_click_filter_enable) {
            [DJRepeatClickHelper repeatClickRegistRunloopObserver];
        }
    });
}

+ (void)setTapDisable
{
    NSAssert([NSThread isMainThread],@"must be main thread");
    bCanTap = NO;
}

+ (BOOL)tapEnable
{
    NSAssert([NSThread isMainThread], @"must be main thread");
    if (dj_repeat_click_filter_enable) {
        BOOL otherFilterResult = _otherRepeatClickFilter ? _otherRepeatClickFilter() : YES;
        return bCanTap && otherFilterResult;
    }else{
        return YES;
    }
}

+ (BOOL)otherConditionCheck
{
    if (_otherRepeatClickFilter) {
        return _otherRepeatClickFilter();
    }
    return YES;
}

+ (void)setOtherFilter:(DJRepeatClickOtherFilterBlock)otherFilter
{
    _otherRepeatClickFilter = otherFilter;
}

+ (void)repeatClickRegistRunloopObserver
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFStringRef runLoopMode = kCFRunLoopCommonModes;
    
    void (^runLoopObserverCallback)(CFRunLoopObserverRef runLoopObserver, CFRunLoopActivity activity) = ^(CFRunLoopObserverRef runLoopObserver, CFRunLoopActivity activity){
        bCanTap = YES;
    };
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                                       kCFRunLoopBeforeWaiting|kCFRunLoopExit,
                                                                       true,
                                                                       INT_MAX-1,
                                                                       runLoopObserverCallback);
    CFRunLoopAddObserver(runLoop, observer, runLoopMode);
    CFRelease(observer);
}

@end

#endif
