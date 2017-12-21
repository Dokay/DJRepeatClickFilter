//
//  UIGestureRecognizer+RepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "UIGestureRecognizer+RepeatClick.h"
#import "DJMethodSwizzleMacro.h"

#import "DJRepeatClickHelper.h"
#import "UIApplication+RepeatClick.h"

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static NSMutableDictionary *_hookGestureSelectorCache;
static const NSString *DJ_REPEAT_CLICK_GESTURE_PRE = @"DJ_REPEAT_CLICK_GESTURE_PRE";
static const NSString *DJ_REPEAT_CLICK_GESTURE_FORK_PRE = @"DJ_REPEAT_CLICK_GESTURE_FORK_PRE";

@implementation UIGestureRecognizer (RepeatClick)

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
    return [self dj_repeatClickInitWithTarget:target action:forkAction];
}

- (void)dj_repeatClickAddTarget:(NSObject *)target action:(SEL)action
{
    SEL forkAction = [self repeatClickForkActionWithTarget:target action:action];
    
    [self dj_repeatClickHookGestureWithTarget:target action:forkAction];
    [self dj_repeatClickAddTarget:target action:forkAction];
}

- (SEL)repeatClickForkActionWithTarget:(NSObject *)target action:(SEL)action
{
    SEL forkAction = action;
    if ([self isMemberOfClass:UITapGestureRecognizer.class]
        || [self isMemberOfClass:UIScreenEdgePanGestureRecognizer.class]) {
        NSString *actionName = NSStringFromSelector(action);
        NSMutableString *formActionName = [[NSMutableString alloc] initWithFormat:@"%@",DJ_REPEAT_CLICK_GESTURE_FORK_PRE];
        [formActionName appendString:@"_"];
        [formActionName appendString:actionName];
        if (![formActionName hasSuffix:@":"]) {
            [formActionName appendString:@":"];
        }
        
        forkAction = NSSelectorFromString(formActionName.copy);
        IMP targetIMP = (IMP)class_getMethodImplementation(target.class, action);
        class_addMethod(target.class, forkAction, targetIMP, method_getTypeEncoding(class_getInstanceMethod([target class], action)));
    }
    return forkAction;
}

- (void)dj_repeatClickHookGestureWithTarget:(NSObject *)target action:(SEL)action
{
    if (!target ||! action) {
        return;
    }
    
    if (![self isMemberOfClass:UITapGestureRecognizer.class]
        && ![self isMemberOfClass:UIScreenEdgePanGestureRecognizer.class]) {
        return;
    }
    
    NSString *selectorKeyWithTargetClass = dj_gesture_selector_name(target.class,action);
    
    if (!_hookGestureSelectorCache) {
        _hookGestureSelectorCache = [NSMutableDictionary new];
    }
    
    if ([_hookGestureSelectorCache valueForKey:selectorKeyWithTargetClass]) {
        return;
    }
    
    Method setterMethod = class_getInstanceMethod([target class], action);
    NSAssert(setterMethod != NULL, @"no selector:",selectorKeyWithTargetClass);
    
    BOOL addMethodResult = class_addMethod(target.class, NSSelectorFromString(selectorKeyWithTargetClass), (IMP)dj_gesture_imp, method_getTypeEncoding(setterMethod));
    
    NSAssert(addMethodResult, @"add method：%@ fail..",selectorKeyWithTargetClass);
    
    DJ_methodSwizzle(target.class, action, NSSelectorFromString(selectorKeyWithTargetClass), YES);
    [_hookGestureSelectorCache setObject:@"1" forKey:selectorKeyWithTargetClass];
}

static void dj_gesture_imp(NSObject *target, SEL action, id newValue)
{
    UIGestureRecognizer *recognizer = newValue;
    
    if ([recognizer isMemberOfClass:UITapGestureRecognizer.class]
        || ([recognizer isMemberOfClass:UIScreenEdgePanGestureRecognizer.class] && recognizer.state == UIGestureRecognizerStateBegan)) {
        if ([DJRepeatClickHelper tapEnable]) {
            [DJRepeatClickHelper setTapDisable];
            [UIApplication setProcessingToCommon];
            
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

NS_INLINE void dj_gesture_invoke(NSObject *target, SEL action, id newValue)
{
    NSString *selectorKeyWithTargetClass = dj_gesture_selector_name(target.class,action);
    IMP originalImplementation = class_getMethodImplementation([target class], NSSelectorFromString(selectorKeyWithTargetClass));
//    NSAssert(originalImplementation != NULL,@"no imp,%@",selectorKeyWithTargetClass);
    assert(originalImplementation != NULL);
    
    typedef void (*OriginalMethodType)(id,SEL, NSObject*);
    OriginalMethodType originalMethod = (OriginalMethodType)originalImplementation;
    originalMethod(target,NSSelectorFromString(selectorKeyWithTargetClass),newValue);
}

NS_INLINE BOOL dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()
{
    return [UIApplication isCommonEqual] && [DJRepeatClickHelper otherConditionCheck];
}

@end

#endif
