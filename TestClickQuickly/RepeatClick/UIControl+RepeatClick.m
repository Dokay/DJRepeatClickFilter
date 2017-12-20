//
//  UIControl+RepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "UIControl+RepeatClick.h"
#import "UIApplication+RepeatClick.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"


#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

@implementation UIControl (RepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (dj_repeat_click_filter_enable) {
            DJ_methodSwizzle(UIControl.class,@selector(sendAction:to:forEvent:),@selector(dj_repeatClickSendAction:to:forEvent:),YES);
        }
    });
}

NS_INLINE BOOL dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()
{
    return [UIApplication isCommonEqual] && [DJRepeatClickHelper otherConditionCheck];
}

#pragma mark - UIControl Hook
- (void)dj_repeatClickSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (event == nil) {
        //UITextInput replaceRange:withText: will call
        [self dj_repeatClickSendAction:action to:target forEvent:event];
        return;
    }
    
    if ([DJRepeatClickHelper tapEnable]) {
        [DJRepeatClickHelper setTapDisable];
        [UIApplication setProcessingToCommon];
        [self dj_repeatClickSendAction:action to:target forEvent:event];
    }else if(dj_RepeatClickGestureAndActionOneTapMultipleSelectorInvokeEnable()){
        [self dj_repeatClickSendAction:action to:target forEvent:event];
    }
}
@end

#endif
