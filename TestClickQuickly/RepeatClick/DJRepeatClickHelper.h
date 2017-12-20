//
//  DJRepeatClickHelper.h
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//

#import <Foundation/Foundation.h>

#define DJ_REPEAT_CLICK_OPEN 1
#define DJ_REPEAT_CLICK_CLOSE 0

#ifndef DJ_REPEAT_CLICK_MACROS
    #define DJ_REPEAT_CLICK_MACROS DJ_REPEAT_CLICK_OPEN
#endif

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

typedef BOOL (^DJRepeatClickOtherFilterBlock)();
__attribute__((weak)) BOOL dj_repeat_click_filter_enable = YES;

@interface DJRepeatClickHelper : NSObject

/**
 设置当前Runloop 点击无效，当前Runloop结束时开关会自动放开，可多次重复调用
 */
+ (void)setTapDisable;

+ (BOOL)tapEnable;
+ (BOOL)otherConditionCheck;
+ (void)setOtherFilter:(DJRepeatClickOtherFilterBlock)otherFilter;


@end

#endif
