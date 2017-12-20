//
//  NSObject+UICollectionViewRepeatClick.m
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//
//

#import "NSObject+UICollectionViewRepeatClick.h"
#import "DJMethodSwizzleMacro.h"
#import "DJRepeatClickHelper.h"


#if DJ_REPEAT_CLICK_MACROS == DJ_REPEAT_CLICK_OPEN

static NSMutableDictionary *hookCollectionClassesCache;

@implementation UICollectionView (RepeatClick)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([DJRepeatClickHelper isFilterOpen]) {
            DJ_methodSwizzle(UICollectionView.class, @selector(setDelegate:), @selector(dj_repeatClickSetCollectionDelegate:), YES);
        }
    });
}

#pragma mark UICollectionView Hook
- (void)dj_repeatClickSetCollectionDelegate:(NSObject *)deleagte
{
    [self dj_repeatClickSetCollectionDelegate:deleagte];
    
    if (hookCollectionClassesCache == nil) {
        hookCollectionClassesCache = [NSMutableDictionary new];
    }
    if (deleagte != nil && [hookCollectionClassesCache objectForKey:NSStringFromClass(deleagte.class)] == nil) {
        BOOL addMethodResult = DJ_addSwizzleMethod(deleagte.class,@selector(dj_repeatClickCollectionView:didSelectItemAtIndexPath:));
        NSAssert(addMethodResult, @"add method fail..");
        
        DJ_methodSwizzle(deleagte.class, @selector(collectionView:didSelectItemAtIndexPath:), @selector(dj_repeatClickCollectionView:didSelectItemAtIndexPath:), YES);
        [hookCollectionClassesCache setObject:@"1" forKey:NSStringFromClass(deleagte.class)];
    }
    
}

- (void)dj_repeatClickCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DJRepeatClickHelper tapEnable]) {
        [DJRepeatClickHelper setTapDisable];
        [self dj_repeatClickCollectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

@end

#endif
