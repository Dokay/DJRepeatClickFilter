//
//  NSObject+UITableViewRepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "NSObject+UITableViewRepeatClick.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"

#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static NSMutableDictionary *hookTableClassesCache;

@implementation NSObject (UITableViewRepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (dj_repeat_click_filter_enable) {
            DJ_methodSwizzle(UITableView.class, @selector(setDelegate:), @selector(dj_repeatClickSetDelegate:), YES);
        }
    });
}

#pragma mark UITableView Hook
- (void)dj_repeatClickSetDelegate:(NSObject *)deleagte
{
    [self dj_repeatClickSetDelegate:deleagte];
    
    if (hookTableClassesCache == nil) {
        hookTableClassesCache = [NSMutableDictionary new];
    }
    if (deleagte != nil && [hookTableClassesCache objectForKey:NSStringFromClass(deleagte.class)] == nil) {
        BOOL addMethodResult = DJ_addSwizzleMethod(deleagte.class,@selector(dj_repeat_tableView:didSelectRowAtIndexPath:));
        NSAssert(addMethodResult, @"add method fail..");
        
        DJ_methodSwizzle(deleagte.class, @selector(tableView:didSelectRowAtIndexPath:), @selector(dj_repeat_tableView:didSelectRowAtIndexPath:), YES);
        [hookTableClassesCache setObject:@"1" forKey:NSStringFromClass(deleagte.class)];
    }
    
}

- (void)dj_repeat_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DJRepeatClickHelper tapEnable]) {
        [DJRepeatClickHelper setTapDisable];
        [self dj_repeat_tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end

#endif
