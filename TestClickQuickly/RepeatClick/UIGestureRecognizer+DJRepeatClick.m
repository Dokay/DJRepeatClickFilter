//
//  UIGestureRecognizer+DJRepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "UIGestureRecognizer+DJRepeatClick.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"
#import "UIApplication+DJRepeatClick.h"
#import "NSObject+DJRepeatClickAddition.h"

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static NSMutableDictionary *_hookGestureSelectorCache;
static const NSString *DJ_REPEAT_CLICK_GESTURE_PRE = @"DJ_REPEAT_CLICK_GESTURE_PRE";
static const NSString *DJ_REPEAT_CLICK_GESTURE_FORK_PRE = @"DJ_REPEAT_CLICK_GESTURE_FORK_PRE";

@implementation UIGestureRecognizer (DJRepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([DJRepeatClickHelper isFilterOpen]) {
            DJ_methodSwizzle(UIGestureRecognizer.class,@selector(initWithTarget:action:),@selector(dj_repeatClickInitWithTarget:action:),YES);
            DJ_methodSwizzle(UIGestureRecognizer.class,@selector(addTarget:action:),@selector(dj_repeatClickAddTarget:action:),YES);
        }
    });
}

#pragma mark - Gesture Hook
- (instancetype)dj_repeatClickInitWithTarget:(nullable NSObject *)target action:(nullable SEL)action
{
    SEL forkAction = [self repeatClickForkActionWithTarget:target action:action];
    
    [self dj_repeatClickHookGestureWithTarget:target action:forkAction];
    //avoid action may be called by other custom method that not by system event, fork action
    return [self dj_repeatClickInitWithTarget:target action:forkAction];
}

- (void)dj_repeatClickAddTarget:(NSObject *)target action:(SEL)action
{
    SEL forkAction = [self repeatClickForkActionWithTarget:target action:action];
    
    [self dj_repeatClickHookGestureWithTarget:target action:forkAction];
    [self dj_repeatClickAddTarget:target action:forkAction];
}


/**
 fork selector and add the forked selector into target class
 format for selector name is DJ_REPEAT_CLICK_GESTURE_FORK_PRE_#actionName:
 
 @param target original target to add fork selector
 @param action original selector
 @return selector forked
 */
- (SEL)repeatClickForkActionWithTarget:(NSObject *)target action:(SEL)action
{
    SEL forkAction = action;
    if ([self isMemberOfClass:UITapGestureRecognizer.class]
        || [self isMemberOfClass:UIScreenEdgePanGestureRecognizer.class]) {
        NSString *actionName = NSStringFromSelector(action);
        NSMutableString *forkActionName = [[NSMutableString alloc] initWithFormat:@"%@",DJ_REPEAT_CLICK_GESTURE_FORK_PRE];
        [forkActionName appendString:@"_"];
        [forkActionName appendString:actionName];
        if (![forkActionName hasSuffix:@":"]) {
            [forkActionName appendString:@":"];
        }
        
        forkAction = NSSelectorFromString(forkActionName.copy);
        IMP targetIMP = (IMP)class_getMethodImplementation(target.class, action);
        class_addMethod(target.class, forkAction, targetIMP, method_getTypeEncoding(class_getInstanceMethod([target class], action)));
    }
    return forkAction;
}


/**
 add custom selector and IMP to target and swizzle with fork action
 format for custom selector is DJ_REPEAT_CLICK_GESTURE_PRE_#targetClassName_#forkSelectorName

 @param target original target
 @param forkAction fork action
 */
- (void)dj_repeatClickHookGestureWithTarget:(NSObject *)target action:(SEL)forkAction
{
    if (!target ||! forkAction) {
        return;
    }
    
    if (![self isMemberOfClass:UITapGestureRecognizer.class]
        && ![self isMemberOfClass:UIScreenEdgePanGestureRecognizer.class]) {
        return;
    }
    
    if (!_hookGestureSelectorCache) {
        _hookGestureSelectorCache = [NSMutableDictionary new];
    }
    
    NSString *selectorKeyWithTargetClass = dj_gesture_selector_name(target.class,forkAction);
    if ([_hookGestureSelectorCache valueForKey:selectorKeyWithTargetClass]) {
        return;
    }
    
    Method originalMethod = class_getInstanceMethod([target class], forkAction);
    NSAssert(originalMethod != NULL, @"no selector:",selectorKeyWithTargetClass);
    
    BOOL addMethodResult = class_addMethod(target.class, NSSelectorFromString(selectorKeyWithTargetClass), (IMP)dj_gesture_imp, method_getTypeEncoding(originalMethod));
    NSAssert(addMethodResult, @"add method：%@ fail..",selectorKeyWithTargetClass);
    
    DJ_methodSwizzle(target.class, forkAction, NSSelectorFromString(selectorKeyWithTargetClass), YES);
    
    [_hookGestureSelectorCache setObject:@"1" forKey:selectorKeyWithTargetClass];
}


/**
 custom IMP to do really action, all user tap gestures will call this method.

 @param target original target
 @param action fork selector
 @param newValue UITapGestureRecognizer param
 */
static void dj_gesture_imp(NSObject *target, SEL action, id newValue)
{
    UIGestureRecognizer *recognizer = newValue;
    if (recognizer.repeatClickFilterDisable) {
        dj_gesture_invoke(target,action,newValue);
        return;
    }
    
    //UIScreenEdgePanGestureRecognizer add here for pan gesture may change navigation stack also.ex->pop
    if ([recognizer isMemberOfClass:UITapGestureRecognizer.class]
        || ([recognizer isMemberOfClass:UIScreenEdgePanGestureRecognizer.class] && recognizer.state == UIGestureRecognizerStateBegan)) {
        if ([DJRepeatClickHelper tapEnable]) {
            [DJRepeatClickHelper setTapDisable];
            [UIApplication setIsProcessingForCurrentTimestap];
            
            dj_gesture_invoke(target,action,newValue);
        }else if(dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()){
            dj_gesture_invoke(target,action,newValue);
        }
    }else{
        dj_gesture_invoke(target,action,newValue);
    }
}

NS_INLINE NSString *dj_gesture_selector_name(Class targetClass, SEL action)
{
    NSString *selectorKeyWithTargetClass = [NSString stringWithFormat:@"%@_%@_%@",DJ_REPEAT_CLICK_GESTURE_PRE,NSStringFromClass(targetClass),NSStringFromSelector(action)];
    return selectorKeyWithTargetClass;
}

/**
 get original IMP and invoke

 @param target original target
 @param action fork selector
 @param newValue UITapGestureRecognizer param
 */
NS_INLINE void dj_gesture_invoke(NSObject *target, SEL action, id newValue)
{
    NSString *selectorKeyWithTargetClass = dj_gesture_selector_name(target.class,action);
    IMP originalImplementation = class_getMethodImplementation([target class], NSSelectorFromString(selectorKeyWithTargetClass));
    assert(originalImplementation != NULL);
    
    typedef void (*OriginalMethodType)(id,SEL, NSObject*);
    OriginalMethodType originalMethod = (OriginalMethodType)originalImplementation;
    originalMethod(target,NSSelectorFromString(selectorKeyWithTargetClass),newValue);
}

NS_INLINE BOOL dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()
{
    return [UIApplication isSameTap] && [DJRepeatClickHelper otherConditionCheck];
}

@end

#endif
