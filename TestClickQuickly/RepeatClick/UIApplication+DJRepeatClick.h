//
//  UIApplication+DJRepeatClick.h
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import <UIKit/UIKit.h>

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

/**
 Use for invoke multiple method for one tap, because UIGestureRecognizer and UIControl can add multple action for one gesture/action.
 */
@interface UIApplication (DJRepeatClick)

/**
 set tag that is process one event,different event has different timestap.
 */
+ (void)setIsProcessingForCurrentTimestap;

/**
 whether is last same tap. if current timestap processing has changed, means there is a new tap while last tap is processing.

 @return YES if user has not tap while processing event,otherwise NO.
 */
+ (BOOL)isSameTap;

@end

#endif
