//
//  DJMethodSwizzleMacro.h
//  TestClickQuickly
//
//  Created by Dokay on 2017/9/25.
//  Copyright © 2017年 dj226. All rights reserved.
//

#ifndef DJMethodSwizzleMacro_h
#define DJMethodSwizzleMacro_h

#import <objc/runtime.h>

NS_INLINE void DJ_methodSwizzle(Class aClass, SEL originalSelector, SEL swizzledSelector, BOOL isInstanceMethod)
{
    Method (*class_getMethod)(Class, SEL) = &class_getInstanceMethod;
    if (!isInstanceMethod) {
        class_getMethod = &class_getClassMethod;
        aClass = object_getClass(aClass);
    }
    Method originalMethod = class_getMethod(aClass, originalSelector);
    Method swizzledMethod = class_getMethod(aClass, swizzledSelector);
    if (class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

NS_INLINE BOOL DJ_addSwizzleMethod(Class aClass, SEL swizzledSelector)
{
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
    BOOL addMethodResult = class_addMethod(aClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    return addMethodResult;
}



#endif /* DJMethodSwizzleMacro_h */
