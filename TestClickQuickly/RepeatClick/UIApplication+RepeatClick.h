//
//  UIApplication+RepeatClick.h
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import <UIKit/UIKit.h>

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

@interface UIApplication (RepeatClick)

+ (void)setProcessingToCommon;
+ (BOOL)isCommonEqual;

@end

#endif
