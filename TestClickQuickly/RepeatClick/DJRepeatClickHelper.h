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

/**
 whether tap event filter is open.

 @return YES means Open,otherwise NO.
 */
+ (BOOL)isFilterOpen;

/**
 set current filter open or not.

 @param isFilterOpen filter open or not.
 */
+ (void)setFilterOpen:(BOOL)isFilterOpen;

/**
 set state can not invoke tap actions in current runloop.
 */
+ (void)setTapDisable;

/**
 whether tap enbale in current runloop.

 @return YES can tap,otherwise NO.
 */
+ (BOOL)tapEnable;

/**
 other condition check result, is result for DJRepeatClickOtherFilterBlock.

 @return YES conditon is OK,otherwise NO.
 */
+ (BOOL)otherConditionCheck;

/**
 set other condition filter block

 @param otherFilter filer block
 */
+ (void)setOtherFilter:(DJRepeatClickOtherFilterBlock)otherFilter;


@end

#endif
