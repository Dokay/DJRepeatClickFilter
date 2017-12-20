//
//  DJRepeatClickHelper.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//

#import "DJRepeatClickHelper.h"

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static BOOL _bCanTap = NO;
static BOOL _isFilterOpen = YES;
static DJRepeatClickOtherFilterBlock _otherRepeatClickFilter;

@implementation DJRepeatClickHelper

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_isFilterOpen) {
            [DJRepeatClickHelper repeatClickRegistRunloopObserver];
        }
    });
}

+ (BOOL)isFilterOpen
{
    NSAssert([NSThread isMainThread],@"must be main thread");
    return _isFilterOpen;
}

+ (void)setFilterOpen:(BOOL)isFilterOpen
{
    NSAssert([NSThread isMainThread],@"must be main thread");
    _isFilterOpen = isFilterOpen;
}

+ (void)setTapDisable
{
    NSAssert([NSThread isMainThread],@"must be main thread");
    _bCanTap = NO;
}

+ (BOOL)tapEnable
{
    NSAssert([NSThread isMainThread], @"must be main thread");
    if (_isFilterOpen) {
        BOOL otherFilterResult = _otherRepeatClickFilter ? _otherRepeatClickFilter() : YES;
        return _bCanTap && otherFilterResult;
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
        _bCanTap = YES;
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
