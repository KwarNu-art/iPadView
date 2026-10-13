#import <Foundation/Foundation.h>  
#import <UIKit/UIKit.h>  
#import <objc/runtime.h>  
 
// --- UIDevice Category for iPad View ---  
@interface UIDevice (iPadView)  
- (UIUserInterfaceIdiom)spoofed_userInterfaceIdiom;  
- (NSString *)spoofed_model;  
@end  
 
@implementation UIDevice (iPadView)  
- (UIUserInterfaceIdiom)spoofed_userInterfaceIdiom {  
   return UIUserInterfaceIdiomPad; // iPad Idiom အဖြစ် သတ်မှတ်ခြင်း (Value: 1)  
}  
 
- (NSString *)spoofed_model {  
   return @"iPad";  
}  
@end  
 
// --- Method Swizzling Helper ---  
static void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {  
   Method originalMethod = class_getInstanceMethod(class, originalSelector);  
   Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);  
   if (originalMethod && swizzledMethod) {  
       method_exchangeImplementations(originalMethod, swizzledMethod);  
   }  
}  
 
// --- Constructor ---  
__attribute__((constructor))  
static void init(void) {  
   @autoreleasepool {  
       Class deviceClass = [UIDevice class];  
       swizzleMethod(deviceClass, @selector(userInterfaceIdiom), @selector(spoofed_userInterfaceIdiom));  
       swizzleMethod(deviceClass, @selector(model), @selector(spoofed_model));  
   }  
}  
