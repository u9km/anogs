#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

// ============================================================================
//  TITANIUM V100: EXTERNAL AEGIS (SYSTEM LEVEL PROTECTION)
//  Tech: Obj-C Swizzling Only (No Memory Hooks / No Binary Touching)
//  Target: External Masking & Log Wiping & ID Spoofing
// ============================================================================

// ----------------------------------------------------------------------------
// 1. قسم مكافحة الباند الغيابي (The Cleaner)
// ينظف الجهاز من الخارج
// ----------------------------------------------------------------------------
void Wipe_External_Logs() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *home = NSHomeDirectory();
    
    // المسارات التي تخزن فيها اللعبة "السموم" (Logs)
    NSArray *targets = @[
        [home stringByAppendingPathComponent:@"Documents/ano_tmp"],
        [home stringByAppendingPathComponent:@"Documents/tss_tmp"],
        [home stringByAppendingPathComponent:@"Library/Caches/com.tencent.ig"],
        [home stringByAppendingPathComponent:@"Library/Preferences/com.tencent.ig.plist"],
        [home stringByAppendingPathComponent:@"tmp"]
    ];

    for (NSString *path in targets) {
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
        }
    }
    NSLog(@"[Titanium External] Disk Cleaned.");
}

// ----------------------------------------------------------------------------
// 2. قسم مكافحة الـ 10 سنوات (ID Spoofer)
// نخدع اللعبة بأننا جهاز جديد في كل مرة (بدون لمس ملفات اللعبة)
// ----------------------------------------------------------------------------
@interface FakeDevice : NSObject
@end

@implementation FakeDevice
- (NSUUID *)fake_identifierForVendor {
    // نولد رقم UUID عشوائي جديد في كل مرة
    return [NSUUID UUID];
}
@end

// ----------------------------------------------------------------------------
// 3. قسم مكافحة الأسبوع والكراك (File Masking)
// نخفي ملفات الجلبريك والشهادات
// ----------------------------------------------------------------------------
@interface FakeFileManager : NSObject
@end

@implementation FakeFileManager
- (BOOL)fake_fileExistsAtPath:(NSString *)path {
    // قائمة الممنوعات الخارجية
    if ([path containsString:@"Cydia"] || 
        [path containsString:@"MobileSubstrate"] || 
        [path containsString:@"embedded.mobileprovision"] || // يخفي أنك كراك
        [path containsString:@"AnogsTitanium"]) {            // يخفي الأداة نفسها
        return NO;
    }
    return [self fake_fileExistsAtPath:path]; // تمرير الملفات السليمة
}
@end

// ----------------------------------------------------------------------------
// 4. المحرك الخارجي (System Swizzler)
// ----------------------------------------------------------------------------
static void Swizzle(Class cls, SEL original, SEL replacement) {
    Method origMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, replacement);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, original, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static __attribute__((constructor)) void Init_External_Shield() {
    
    // 1. التنظيف فور التشغيل
    Wipe_External_Logs();
    
    // 2. تفعيل الخداع (Swizzling)
    // نحن هنا نعدل كلاسات "النظام" (UIDevice, NSFileManager) وليس اللعبة
    
    // خداع الهوية (ضد باند الجهاز)
    Swizzle([UIDevice class], @selector(identifierForVendor), @selector(fake_identifierForVendor));
    
    // خداع الملفات (ضد كشف الكراك)
    Swizzle([NSFileManager class], @selector(fileExistsAtPath:), @selector(fake_fileExistsAtPath:));
    
    NSLog(@"[Titanium V100] External Aegis Active. Game files untouched.");
}
