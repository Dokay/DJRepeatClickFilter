//
//  UIControl+DJRepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "UIControl+DJRepeatClick.h"
#import "UIApplication+DJRepeatClick.h"
#import "NSObject+DJRepeatClickAddition.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"


#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

@implementation UIControl (DJRepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([DJRepeatClickHelper isFilterOpen]) {
            DJ_methodSwizzle(UIControl.class,@selector(sendAction:to:forEvent:),@selector(dj_repeatClickSendAction:to:forEvent:),YES);
        }
    });
}

NS_INLINE BOOL dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()
{
    return [UIApplication isSameTap] && [DJRepeatClickHelper otherConditionCheck];
}

#pragma mark - UIControl Hook
- (void)dj_repeatClickSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (self.repeatClickFilterDisable) {
        [self dj_repeatClickSendAction:action to:target forEvent:event];
        return;
    }
    
    if (event == nil) {
        //UITextInput replaceRange:withText: will call
        [self dj_repeatClickSendAction:action to:target forEvent:event];
        return;
    }
    
    if ([DJRepeatClickHelper tapEnable]) {
        [DJRepeatClickHelper setTapDisable];
        [UIApplication setIsProcessingForCurrentTimestap];
        [self dj_repeatClickSendAction:action to:target forEvent:event];
    }else if(dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()){
        [self dj_repeatClickSendAction:action to:target forEvent:event];
    }
}
@end

#endif
