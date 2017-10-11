//
//  UIView+DJRepeatClickFilter.h
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//  Copyright © 2017年 dj226. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^DJRepeatClickOtherFilter)();

__attribute__((weak)) BOOL DJRepeatClickFilterEnable = YES;

@interface NSObject (DJRepeatClickFilter)

+ (void)setOtherFilter:(DJRepeatClickOtherFilter)otherFilter;

@end
