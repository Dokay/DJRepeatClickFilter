//
//  UIView+DJRepeatClickFilter.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//  Copyright © 2017年 dj226. All rights reserved.
//

#import "UIView+DJRepeatClickFilter.h"
#import <objc/runtime.h>

static BOOL bCanTap = NO;
static NSMutableDictionary *hookTableClassesCache;
static NSMutableDictionary *hookCollectionClassesCache;
static NSMutableDictionary *hookGestureSelectorCache;
static const NSString *DJ_REPEAT_CLICK_GESTURE_PRE = @"DJ_REPEAT_CLICK_GESTURE_PRE";

static DJRepeatClickOtherFilter _otherFilter;

NS_INLINE void DJ_methodSwizzle_new(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector, BOOL isInstanceMethod)
{
    Method (*class_getMethod)(Class, SEL) = &class_getInstanceMethod;
    if (!isInstanceMethod) {
        class_getMethod = &class_getClassMethod;
        originalClass = object_getClass(originalClass);
        swizzledClass = object_getClass(swizzledClass);
    }
    Method originalMethod = class_getMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getMethod(swizzledClass, swizzledSelector);
    if (class_addMethod(originalClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(originalClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

NS_INLINE void DJ_methodSwizzle(Class aClass, SEL originalSelector, SEL swizzledSelector, BOOL isInstanceMethod)
{
    DJ_methodSwizzle_new(aClass, originalSelector, aClass, swizzledSelector, isInstanceMethod);
}

NS_INLINE BOOL DJ_addSwizzleMethod(Class aClass, SEL swizzledSelector)
{
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
    BOOL addMethodResult = class_addMethod(aClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    return addMethodResult;
}

@implementation NSObject (DJRepeatClickFilter)

+ (void)setOtherFilter:(DJRepeatClickOtherFilter)otherFilter
{
    _otherFilter = otherFilter;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (DJRepeatClickFilterEnable) {
            [UIView dj_repeat_registRunloopObserver];
            DJ_methodSwizzle(UITableView.class, @selector(setDelegate:), @selector(dj_repeat_setDelegate:), YES);
            DJ_methodSwizzle(UICollectionView.class, @selector(setDelegate:), @selector(dj_repeat_setCollectionDelegate:), YES);
            DJ_methodSwizzle(UIControl.class,@selector(sendAction:to:forEvent:),@selector(dj_repeat_sendAction:to:forEvent:),YES);
            DJ_methodSwizzle(UIGestureRecognizer.class,@selector(initWithTarget:action:),@selector(dj_initWithTarget:action:),YES);
            DJ_methodSwizzle(UIGestureRecognizer.class,@selector(addTarget:action:),@selector(dj_addTarget:action:),YES);
        }
    });
}

+ (void)dj_repeat_registRunloopObserver
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

+ (BOOL)dj_repeat_checkSafe
{
    if (DJRepeatClickFilterEnable) {
        BOOL otherFilterResult = _otherFilter ? _otherFilter() : YES;
        return bCanTap && otherFilterResult;
    }else{
        return YES;
    }
}

#pragma mark - UITableView Hook
- (void)dj_repeat_setDelegate:(NSObject *)deleagte
{
    [self dj_repeat_setDelegate:deleagte];
    
    if (hookTableClassesCache == nil) {
        hookTableClassesCache = [NSMutableDictionary new];
    }
    if (deleagte != nil && [hookTableClassesCache objectForKey:NSStringFromClass(deleagte.class)] == nil) {
        BOOL addMethodResult = DJ_addSwizzleMethod(deleagte.class,@selector(dj_repeat_tableView:didSelectRowAtIndexPath:));
        NSAssert(addMethodResult, @"add method fail..");
        
        DJ_methodSwizzle(deleagte.class, @selector(tableView:didSelectRowAtIndexPath:), @selector(dj_repeat_tableView:didSelectRowAtIndexPath:), YES);
        [hookTableClassesCache setObject:@"1" forKey:NSStringFromClass(deleagte.class)];
    }
    
}

- (void)dj_repeat_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NSObject dj_repeat_checkSafe]) {
        bCanTap = NO;
        [self dj_repeat_tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UIControl Hook
- (void)dj_repeat_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (event == nil) {
        //UITextInput replaceRange:withText: will call
        [self dj_repeat_sendAction:action to:target forEvent:event];
        return;
    }
    
    if ([NSObject dj_repeat_checkSafe]) {
        bCanTap = NO;
        [self dj_repeat_sendAction:action to:target forEvent:event];
    }
}

#pragma mark - UICollectionView Hook
- (void)dj_repeat_setCollectionDelegate:(NSObject *)deleagte
{
    [self dj_repeat_setCollectionDelegate:deleagte];
    
    if (hookCollectionClassesCache == nil) {
        hookCollectionClassesCache = [NSMutableDictionary new];
    }
    if (deleagte != nil && [hookCollectionClassesCache objectForKey:NSStringFromClass(deleagte.class)] == nil) {
        BOOL addMethodResult = DJ_addSwizzleMethod(deleagte.class,@selector(dj_repeat_collectionView:didSelectItemAtIndexPath:));
        NSAssert(addMethodResult, @"add method fail..");
        
        DJ_methodSwizzle(deleagte.class, @selector(collectionView:didSelectItemAtIndexPath:), @selector(dj_repeat_collectionView:didSelectItemAtIndexPath:), YES);
        [hookCollectionClassesCache setObject:@"1" forKey:NSStringFromClass(deleagte.class)];
    }
    
}

- (void)dj_repeat_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NSObject dj_repeat_checkSafe]) {
        bCanTap = NO;
        [self dj_repeat_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - Gesture Hook
- (instancetype)dj_initWithTarget:(nullable id)target action:(nullable SEL)action
{
    [self dj_hookGestureWithTarget:target action:action];
    return [self dj_initWithTarget:target action:action];
}

- (void)dj_addTarget:(id)target action:(SEL)action
{
    [self dj_hookGestureWithTarget:target action:action];
    [self dj_addTarget:target action:action];
}

- (void)dj_hookGestureWithTarget:(NSObject *)target action:(SEL)action
{
    if (!target ||! action) {
        return;
    }
    
    NSString *selectorKeyWithTargetClass = dj_gesture_selector_name(target,action);
    
    if (!hookGestureSelectorCache) {
        hookGestureSelectorCache = [NSMutableDictionary new];
    }
    
    if ([hookGestureSelectorCache valueForKey:selectorKeyWithTargetClass]) {
        return;
    }
    
    Method setterMethod = class_getInstanceMethod([target class], action);
    NSAssert(setterMethod != NULL, @"no selector:",selectorKeyWithTargetClass);
    
    BOOL addMethodResult = class_addMethod(target.class, NSSelectorFromString(selectorKeyWithTargetClass), (IMP)dj_gestureInvokeWithParam, method_getTypeEncoding(setterMethod));
    
    NSAssert(addMethodResult, @"add method：%@ fail..",selectorKeyWithTargetClass);
    
    DJ_methodSwizzle(target.class, action, NSSelectorFromString(selectorKeyWithTargetClass), YES);
    [hookGestureSelectorCache setObject:@"1" forKey:selectorKeyWithTargetClass];
}

NS_INLINE NSString * dj_gesture_selector_name(NSObject *target, SEL action)
{
    NSString *selectorKeyWithTargetClass = [NSString stringWithFormat:@"%@_%@_%@",DJ_REPEAT_CLICK_GESTURE_PRE,NSStringFromClass(target.class),NSStringFromSelector(action)];
    return selectorKeyWithTargetClass;
}

NS_INLINE void dj_gesture_invoke(NSObject *target, SEL action, id newValue)
{
    NSString *selectorKeyWithTargetClass = dj_gesture_selector_name(target,action);
    IMP originalImplementation = class_getMethodImplementation([target class], NSSelectorFromString(selectorKeyWithTargetClass));
//    NSAssert(originalImplementation != NULL,@"no imp,%@",selectorKeyWithTargetClass);
    
    typedef void (*OriginalMethodType)(id,SEL, NSObject*);
    OriginalMethodType originalMethod = (OriginalMethodType)originalImplementation;
    originalMethod(target,NSSelectorFromString(selectorKeyWithTargetClass),newValue);
}

static void dj_gestureInvokeWithParam(NSObject *target, SEL action, id newValue)
{
    UITapGestureRecognizer *currentRecognizer = newValue;
    
//    //gesture can add multiple target, they have one recognizer instance.
//    if (lastRecognizer && lastRecognizer.view == currentRecognizer.view) {
//        CGPoint p1 = [lastRecognizer locationInView:lastRecognizer.view];
//        CGPoint p2 = [currentRecognizer locationInView:currentRecognizer.view];
//        if (CGPointEqualToPoint(p1, p2)) {
//            hd_gesture_invoke(target,action,newValue);
//            return;
//        }
//    }
    
    if ([currentRecognizer isMemberOfClass:UITapGestureRecognizer.class]
        || ([currentRecognizer isMemberOfClass:UIScreenEdgePanGestureRecognizer.class] && currentRecognizer.state == UIGestureRecognizerStateBegan)) {
        if ([NSObject dj_repeat_checkSafe]) {
            bCanTap = NO;
            dj_gesture_invoke(target,action,newValue);
        }
    }else{
        dj_gesture_invoke(target,action,newValue);
    }
}


@end
