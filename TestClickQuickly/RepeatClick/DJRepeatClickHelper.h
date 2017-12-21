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

typedef BOOL (^DJRepeatClickOtherFilterBlock)(void);

@interface DJRepeatClickHelper : NSObject

+ (BOOL)isFilterOpen;
+ (void)setFilterOpen:(BOOL)isFilterOpen;

/**
 can not invoke tap actions in current runloop.
 */
+ (void)setTapDisable;

+ (BOOL)tapEnable;
+ (BOOL)otherConditionCheck;
+ (void)setOtherFilter:(DJRepeatClickOtherFilterBlock)otherFilter;


@end

#endif
