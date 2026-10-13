import 
import 
import 
// Method Swizzling Utility
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
// 1. UIDevice Hooking (Device Identity = iPad)
@interface UIDevice (UniversalIPad)
@end
@implementation UIDevice (UniversalIPad)
- (UIUserInterfaceIdiom)custom_userInterfaceIdiom {
    return UIUserInterfaceIdiomPad; // Value = 1 (iPad)
}
- (NSString )custom_model {
    return @"iPad";
}
@end
// 2. UITraitCollection Hooking (Regular Size Classes)
@interface UITraitCollection (UniversalIPad)
@end
@implementation UITraitCollection (UniversalIPad)
- (UIUserInterfaceIdiom)custom_userInterfaceIdiom {
    return UIUserInterfaceIdiomPad;
}
- (UIUserInterfaceSizeClass)custom_horizontalSizeClass {
    return UIUserInterfaceSizeClassRegular; // Two-Column / Split View Trigger
}
- (UIUserInterfaceSizeClass)custom_verticalSizeClass {
    return UIUserInterfaceSizeClassRegular;
}
@end
// 3. UIWindow Hooking (App Window တစ်ခုလုံးကို iPad Layout အဖြစ် Force ချခြင်း)
@interface UIWindow (UniversalIPad)
@end
@implementation UIWindow (UniversalIPad)
- (UITraitCollection )custom_traitCollection {
    UITraitCollection baseTrait = [self custom_traitCollection];
    UITraitCollection padIdiom = [UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomPad];
    UITraitCollection hRegular = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
    UITraitCollection vRegular = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassRegular];
    
    return [UITraitCollection traitCollectionWithTraitsFromCollections:@[baseTrait, padIdiom, hRegular, vRegular]];
}
@end
// 4. Initalization
__attribute__((constructor))
static void initUniversalIPadMode(void) {
    @autoreleasepool {
        Class deviceClass = [UIDevice class];
        Class traitClass = [UITraitCollection class];
        Class windowClass = [UIWindow class];
        // UIDevice Hooks
        SwizzleMethod(deviceClass, @selector(userInterfaceIdiom), @selector(custom_userInterfaceIdiom));
        SwizzleMethod(deviceClass, @selector(model), @selector(custom_model));
        // UITraitCollection Hooks
        SwizzleMethod(traitClass, @selector(userInterfaceIdiom), @selector(custom_userInterfaceIdiom));
        SwizzleMethod(traitClass, @selector(horizontalSizeClass), @selector(custom_horizontalSizeClass));
        SwizzleMethod(traitClass, @selector(verticalSizeClass), @selector(custom_verticalSizeClass));
        // UIWindow Hooks
        SwizzleMethod(windowClass, @selector(traitCollection), @selector(custom_traitCollection));
        NSLog(@"[Universal iPadView] iPad Layout Activated for this App!");
    }
}
