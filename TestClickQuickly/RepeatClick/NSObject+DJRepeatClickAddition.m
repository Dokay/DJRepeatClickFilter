//
//  NSObject+DJRepeatClickAddition.m
//  TestClickQuickly
//
//  Created by Dokay on 2018/2/2.
//  Copyright © 2018年 dj226. All rights reserved.
//

#import "NSObject+DJRepeatClickAddition.h"
#import <objc/runtime.h>

@implementation NSObject(DJRepeatClickAddition)

- (void)setRepeatClickFilterDisable:(BOOL)repeatClickFilterDisable
{
    objc_setAssociatedObject(self, @selector(repeatClickFilterDisable), @(repeatClickFilterDisable), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)repeatClickFilterDisable
{
    NSNumber *enable = objc_getAssociatedObject(self, _cmd);
    return enable.boolValue;
}

@end
