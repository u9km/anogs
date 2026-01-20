#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

// ============================================================================
//  TITANIUM V101: TOTAL DOMINANCE (NETWORK FIREWALL EDITION)
//  Tech: URL Swizzling + Log Wiping + ID Spoofing
//  Target: Protects against Aimbot/Magic detection by blocking report URLs.
// ============================================================================

// --- 1. جدار الحماية (The Firewall) ---
// هذا الجزء يمنع إرسال تقارير "تفعيلات الفل" للسيرفر
// ----------------------------------------------------------------------------
@interface FakeURLSession : NSObject
@end

@implementation FakeURLSession
// اعتراض طلبات الشبكة
- (NSURLSessionDataTask *)fake_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    
    NSString *url = [[request URL] absoluteString];
    
    // قائمة الكلمات المحظورة (روابط التبليغ عن الايمبوت)
    if ([url containsString:@"report"] || 
        [url containsString:@"log"] || 
        [url containsString:@"dataflow"] || 
        [url containsString:@"analytics"] ||
        [url containsString:@"cs.mbgame"]) { // سيرفر الحماية المعروف
        
        // إذا كان الرابط مشبوهاً، نلغي الطلب بصمت
        // ونعيد "خطأ وهمي" لكي تظن اللعبة أن النت ضعيف فقط
        if (completionHandler) {
            completionHandler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]);
        }
        return nil; // قطع الاتصال
    }
    
    // الروابط العادية (اللعب، الدخول) تمر بسلام
    return [self fake_dataTaskWithRequest:request completionHandler:completionHandler];
}
@end

// --- 2. منظف السجلات (Anti-Ghayabi) ---
void Wipe_Traces() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *home = NSHomeDirectory();
    NSArray *targets = @[
        [home stringByAppendingPathComponent:@"Documents/ano_tmp"],
        [home stringByAppendingPathComponent:@"Documents/tss_tmp"],
        [home stringByAppendingPathComponent:@"Library/Caches/com.tencent.ig"],
        [home stringByAppendingPathComponent:@"Library/Preferences/com.tencent.ig.plist"]
    ];
    for (NSString *path in targets) {
        if ([fm fileExistsAtPath:path]) [fm removeItemAtPath:path error:nil];
    }
}

// --- 3. مخادع الهوية (ID Spoofer) ---
@interface FakeDevice : NSObject
@end
@implementation FakeDevice
- (NSUUID *)fake_identifierForVendor {
    return [NSUUID UUID]; // هوية جديدة كل مرة
}
@end

// --- 4. مخادع الملفات (File Mask) ---
@interface FakeFileManager : NSObject
@end
@implementation FakeFileManager
- (BOOL)fake_fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Cydia"] || [path containsString:@"MobileSubstrate"] || 
        [path containsString:@"embedded"] || [path containsString:@"Anogs"]) return NO;
    return [self fake_fileExistsAtPath:path];
}
@end

// --- 5. المحرك (Swizzler) ---
static void Swizzle(Class cls, SEL original, SEL replacement) {
    Method origMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, replacement);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, original, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static __attribute__((constructor)) void Init_Dominance() {
    Wipe_Traces();
    
    // تفعيل حماية الجهاز والملفات
    Swizzle([UIDevice class], @selector(identifierForVendor), @selector(fake_identifierForVendor));
    Swizzle([NSFileManager class], @selector(fileExistsAtPath:), @selector(fake_fileExistsAtPath:));
    
    // تفعيل جدار الحماية الشبكي (URLSession)
    // هذا آمن جداً في iOS 18 ولا يسبب كراش مثل هوك (connect)
    Class sessionClass = [NSURLSession class];
    Swizzle(sessionClass, @selector(dataTaskWithRequest:completionHandler:), @selector(fake_dataTaskWithRequest:completionHandler:));
    
    NSLog(@"[Titanium V101] Firewall Active. Full-Rage Protection ON.");
}
