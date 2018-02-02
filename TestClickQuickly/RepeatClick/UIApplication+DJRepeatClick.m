//
//  UIApplication+DJRepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "UIApplication+DJRepeatClick.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"


#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static NSTimeInterval _lastTimestamp;
static NSTimeInterval _tapProcessingTimestamp;

@implementation UIApplication (DJRepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([DJRepeatClickHelper isFilterOpen]) {
            DJ_methodSwizzle(UIApplication.class,@selector(sendEvent:),@selector(dj_repeatClickSendEvent:),YES);
        }
    });
}

+ (void)setIsProcessingForCurrentTimestap
{
    _tapProcessingTimestamp = _lastTimestamp;
}

+ (BOOL)isSameTap
{
    return _tapProcessingTimestamp == _lastTimestamp;
}

-(void)dj_repeatClickSendEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        _lastTimestamp = event.timestamp;
    }
    
    [self dj_repeatClickSendEvent:event];
}

@end
#endif
