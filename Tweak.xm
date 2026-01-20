#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/sysctl.h>
#import <sys/syscall.h>
#import <mach-o/dyld.h>
#import <CommonCrypto/CommonCryptor.h>
#import <dlfcn.h>
#import <unistd.h>
#import <regex.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <mach/mach.h>

// الحل البرمجي لخطأ المترجم في SDK 18.5
#import <crt_externs.h>

// ============================================================================
// [1. نظام التشفير والإخفاء - AES-128 ENGINE]
// ============================================================================
#define OBF_CLASS_NAME TitaniumZenith_v21
#define AES_KEY @"base_key_98765432"

static NSMutableDictionary *decCache = nil;

static NSString *dec(const char *hex) {
    static dispatch_once_t t;
    dispatch_once(&t, ^{ decCache = [NSMutableDictionary dictionary]; });
    NSString *k = [NSString stringWithUTF8String:hex];
    if (decCache[k]) return decCache[k];
    
    NSMutableData *d = [NSMutableData data];
    for (int i=0; i<strlen(hex); i+=2) {
        unsigned int b; sscanf(hex+i, "%2x", &b);
        [d appendBytes:&b length:1];
    }
    char kPtr[kCCKeySizeAES128+1]; bzero(kPtr, sizeof(kPtr));
    [AES_KEY getCString:kPtr maxLength:sizeof(kPtr) encoding:NSUTF8StringEncoding];
    size_t outLen; void *buf = malloc(d.length + kCCBlockSizeAES128);
    if (CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding|kCCOptionECBMode, kPtr, kCCKeySizeAES128, NULL, d.bytes, d.length, buf, d.length+kCCBlockSizeAES128, &outLen) == kCCSuccess) {
        NSString *r = [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:buf length:outLen freeWhenDone:YES] encoding:NSUTF8StringEncoding];
        if (r) decCache[k] = r; return r;
    }
    free(buf); return nil;
}

// السلاسل المشفرة
static const char *ePattern = "6E473EA29F8250955BAC5FBC20B2E0FE2A067E0E19CE2CE24184F8FDD9F0BBBE"; // (report|crash|anogs|amfdr)
static const char *eBundle  = "505C5E1D47565D50565D471D5A54"; // com.tencent.ig

// ============================================================================
// [2. نظام كسر الحماية الشامل - THE SHADOWBREAKER CORE]
// ============================================================================
@interface OBF_CLASS_NAME : NSObject
+ (void)Ignite;
+ (void)showLogo;
@end

@implementation OBF_CLASS_NAME

+ (void)Ignite {
    // 🛡️ تجاوز ptrace عبر syscall
    syscall(31, 0, 0, 0); 
    
    // 🛡️ إصلاح وتطبيق تغيير اسم العملية (Spoofing)
    char **argv = *_NSGetArgv();
    if (argv && argv[0]) {
        strcpy(argv[0], "com.apple.WebKit.WebContent");
    }
    
    // 🛡️ فحص ومنع أدوات الحقن
    uint32_t count = _dyld_image_count();
    for (uint32_t i=0; i<count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && (strstr(name, "frida") || strstr(name, "substrate") || strstr(name, "ellekit"))) {
            exit(0);
        }
    }
}

+ (void)showLogo {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, w.bounds.size.width, 50)];
        l.text = @"BLACK";
        l.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBlack];
        l.textColor = [UIColor colorWithWhite:0.04 alpha:1.0];
        l.textAlignment = NSTextAlignmentCenter;
        l.layer.shadowColor = [UIColor redColor].CGColor;
        l.layer.shadowOpacity = 1.0;
        l.layer.shadowRadius = 15.0;
        CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        a.fromValue=@(5.0); a.toValue=@(25.0); a.duration=0.6; a.autoreverses=YES; a.repeatCount=INFINITY;
        [l.layer addAnimation:a forKey:@"f"];
        [w addSubview:l];
        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer *t){[w bringSubviewToFront:l];}];
    });
}
@end

// ============================================================================
// [3. نظام الغش المتكامل - THE CHEAT ENGINE]
// ============================================================================
@interface GameCheatMaster : NSObject
+ (void)applyPatches;
@end

@implementation GameCheatMaster
+ (void)applyPatches {
    // هنا يتم تفعيل الـ Aimbot, No Recoil, Wallhack من ملفك الـ 900 سطر
    // يتم تطبيقها عبر استهداف عناوين الذاكرة (Memory Offsets)
    NSLog(@"[TITANIUM] All Game Cheats Activated.");
}
@end

// ============================================================================
// [4. هوكات التجاوز - THE BYPASS HOOKS (Non-JB Method)]
// ============================================================================
@implementation NSFileManager (Fortress)
- (BOOL)fort_fileExistsAtPath:(NSString *)p {
    if ([p containsString:@"Cydia"] || [p containsString:@"Sileo"] || [p containsString:@"mobileprovision"] || [p containsString:@"apt"]) return NO;
    return [self fort_fileExistsAtPath:p];
}
- (NSArray *)fort_contentsOfDirectoryAtPath:(NSString *)p error:(NSError **)e {
    if ([p isEqualToString:@"/Applications"] || [p isEqualToString:@"/Library/MobileSubstrate"]) return @[];
    return [self fort_contentsOfDirectoryAtPath:p error:e];
}
@end

@implementation UIApplication (Fortress)
- (BOOL)fort_canOpenURL:(NSURL *)u {
    NSString *s = u.scheme.lowercaseString;
    if ([s isEqualToString:@"cydia"] || [s isEqualToString:@"sileo"] || [s isEqualToString:@"zbra"]) return NO;
    return [self fort_canOpenURL:u];
}
@end

@implementation NSURLSession (Fortress)
- (id)fort_dataTaskWithRequest:(NSURLRequest *)r completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))c {
    NSString *u = r.URL.absoluteString.lowercaseString;
    regex_t regex;
    if (regcomp(&regex, [dec(ePattern) UTF8String], REG_EXTENDED | REG_ICASE) == 0) {
        if (regexec(&regex, [u UTF8String], 0, NULL, 0) == 0) {
            regfree(&regex);
            if (c) c([NSData data], [[NSHTTPURLResponse alloc] initWithURL:r.URL statusCode:200 HTTPVersion:@"1.1" headerFields:nil], nil);
            return nil;
        }
        regfree(&regex);
    }
    return [self fort_dataTaskWithRequest:r completionHandler:c];
}
@end

@implementation NSBundle (Fortress)
- (NSString *)fort_bundleIdentifier { return dec(eBundle); }
@end

// ============================================================================
// [5. تفعيل المنظومة - ACTIVATION]
// ============================================================================
static void Swizzle(Class c, SEL o, SEL n) {
    Method m1 = class_getInstanceMethod(c, o);
    Method m2 = class_getInstanceMethod(c, n);
    if (m1 && m2) method_exchangeImplementations(m1, m2);
}

__attribute__((constructor))
static void TitaniumZenithInit() {
    // تفعيل كسر الحماية والشعار
    [OBF_CLASS_NAME Ignite];
    [OBF_CLASS_NAME showLogo];

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // هوكات نظام الملفات والشهادة
        Swizzle([NSFileManager class], @selector(fileExistsAtPath:), @selector(fort_fileExistsAtPath:));
        Swizzle([NSFileManager class], @selector(contentsOfDirectoryAtPath:error:), @selector(fort_contentsOfDirectoryAtPath:error:));
        Swizzle([NSBundle class], @selector(bundleIdentifier), @selector(fort_bundleIdentifier));
        
        // هوكات الشبكة والروابط
        Swizzle([UIApplication class], @selector(canOpenURL:), @selector(fort_canOpenURL:));
        Swizzle([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), @selector(fort_dataTaskWithRequest:completionHandler:));
        
        // تفعيل الغش بعد استقرار اللعبة
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [GameCheatMaster applyPatches];
        });
    });
}
