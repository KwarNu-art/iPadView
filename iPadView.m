import 
import 
import 
static void SwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (!originalMethod || !swizzledMethod) return;
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
// 1. Force iPad Device Identity
@interface UIDevice (UniversalIPad)
@end
@implementation UIDevice (UniversalIPad)
- (UIUserInterfaceIdiom)custom_userInterfaceIdiom {
    return UIUserInterfaceIdiomPad;
}
- (NSString )custom_model {
    return @"iPad";
}
@end
// 2. Force iPad Trait Collection (Regular Size Classes)
@interface UITraitCollection (UniversalIPad)
@end
@implementation UITraitCollection (UniversalIPad)
- (UIUserInterfaceIdiom)custom_userInterfaceIdiom {
    return UIUserInterfaceIdiomPad;
}
- (UIUserInterfaceSizeClass)custom_horizontalSizeClass {
    return UIUserInterfaceSizeClassRegular;
}
- (UIUserInterfaceSizeClass)custom_verticalSizeClass {
    return UIUserInterfaceSizeClassRegular;
}
@end
// 3. Constructor
__attribute__((constructor))
static void initUniversalIPadMode(void) {
    @autoreleasepool {
        Class deviceClass = [UIDevice class];
        Class traitClass = [UITraitCollection class];
        SwizzleMethod(deviceClass, @selector(userInterfaceIdiom), @selector(custom_userInterfaceIdiom));
        SwizzleMethod(deviceClass, @selector(model), @selector(custom_model));
        SwizzleMethod(traitClass, @selector(userInterfaceIdiom), @selector(custom_userInterfaceIdiom));
        SwizzleMethod(traitClass, @selector(horizontalSizeClass), @selector(custom_horizontalSizeClass));
        SwizzleMethod(traitClass, @selector(verticalSizeClass), @selector(custom_verticalSizeClass));
        NSLog(@"[Universal iPadView] Injected Successfully!");
    }
}
