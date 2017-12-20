//
//  UIApplication+RepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "UIApplication+RepeatClick.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"


#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static NSTimeInterval commonTimestamp;
static NSTimeInterval tapProcessingTimestamp;

@implementation UIApplication (RepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([DJRepeatClickHelper isFilterOpen]) {
            DJ_methodSwizzle(UIApplication.class,@selector(sendEvent:),@selector(dj_repeatClickSendEvent:),YES);
        }
    });
}

+ (void)setProcessingToCommon
{
    tapProcessingTimestamp = commonTimestamp;
}

+ (BOOL)isCommonEqual
{
    return tapProcessingTimestamp == commonTimestamp;
}

-(void)dj_repeatClickSendEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        commonTimestamp = event.timestamp;
    }
    
    [self dj_repeatClickSendEvent:event];
}

@end
#endif
