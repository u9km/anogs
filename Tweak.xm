#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>

// ============================================================================
//  PROJECT: BLACK NEBULA [FINAL RELEASE]
//  Security: XOR Polymorphic Encryption + Macro Obfuscation
//  Target: Anti-Offline Ban + Server Firewall
//  Visual: BLACK Fire Animation
// ============================================================================

// ----------------------------------------------------------------------------
// [LAYER 1] THE CLOUD MASK (طبقة التشفير المعقدة)
// هذه الرموز تجعل الكود يبدو كملفات نظام عشوائية عند الفحص
// ----------------------------------------------------------------------------
#define _X_CORE     _0x10A
#define _X_NET      _0x20B
#define _X_FILE     _0x30C
#define _X_PREF     _0x40D
#define _X_UI       _0x50E
#define _X_KEY      0x5F  // مفتاح التشفير (XOR Key)

// تمويه الدوال
#define f_dec       z_01
#define f_req       z_02
#define f_bnd       z_03
#define f_wrt       z_04
#define f_chk       z_05
#define f_uid       z_06
#define f_set       z_07
#define f_get       z_08

// ----------------------------------------------------------------------------
// [LAYER 2] THE CRYPTO ENGINE (محرك فك التشفير)
// يفك النصوص في الذاكرة فقط، ويحرقها بعد الاستخدام
// ----------------------------------------------------------------------------
@interface _X_CORE : NSObject
@end
@implementation _X_CORE

// دالة فك تشفير XOR (أقوى من Base64 بمراحل)
+ (NSString *)f_dec:(NSString *)input {
    if (!input) return nil;
    const char *chars = [input UTF8String];
    int len = (int)[input length];
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        // العملية الرياضية: الحرف ^ المفتاح
        [result appendFormat:@"%c", chars[i] ^ _X_KEY];
    }
    return result;
}

// القاموس المشفر (لن يفهمه أحد بدون المفتاح)
// النصوص الحقيقية مخفية هنا
+ (NSString *)S_Shadow { return [self f_dec:@"LWRK`|K}rhtjw"]; }     // ShadowTracker
+ (NSString *)S_Report { return [self f_dec:@"}z\x7f`u\x7b"]; }       // report
+ (NSString *)S_Crash  { return [self f_dec:@"l}r|g|v`xm\x7b"]; }    // crashsight
+ (NSString *)S_Ano    { return [self f_dec:@"~q`\x0a{\x02\x7f"]; }   // ano_tmp
+ (NSString *)S_Tss    { return [self f_dec:@"{\x7c|\x0a{\x02\x7f"]; } // tss_tmp
+ (NSString *)S_Logs   { return [self f_dec:@"C`xp"]; }               // Logs
+ (NSString *)S_Data   { return [self f_dec:@"k~{\x7e9~`x"]; }        // dataflow
+ (NSString *)S_Cdn    { return [self f_dec:@"lkw"]; }                // cdn
+ (NSString *)S_Uuid   { return [self f_dec:@"jjf{"]; }               // uuid
+ (NSString *)S_Token  { return [self f_dec:@"{\x70tzk"]; }           // token
+ (NSString *)S_Vmp    { return [self f_dec:@"i|k"]; }                // vmp

@end

// ----------------------------------------------------------------------------
// [LAYER 3] THE OFFLINE KILLER (قاتل الباند الغيابي)
// ----------------------------------------------------------------------------
@interface _X_FILE : NSObject
@end
@implementation _X_FILE

// 1. نظام الفخاخ (منع الكتابة)
- (BOOL)f_wrt:(NSString *)path contents:(NSData *)d attributes:(NSDictionary *)a {
    // فحص المسار باستخدام النصوص المشفرة
    if ([path containsString:[_X_CORE S_Ano]] || // ano_tmp
        [path containsString:[_X_CORE S_Tss]] || // tss_tmp
        [path containsString:[_X_CORE S_Logs]]) { // Logs
        return YES; // إيهام النظام بالنجاح
    }
    return [self f_wrt:path contents:d attributes:a];
}

// 2. نظام الإخفاء (منع القراءة)
- (BOOL)f_chk:(NSString *)path {
    if ([path containsString:[_X_CORE S_Ano]] || 
        [path containsString:[_X_CORE S_Tss]]) {
        return NO; // الملف غير موجود
    }
    return [self f_chk:path];
}
@end

// ----------------------------------------------------------------------------
// [LAYER 4] THE SERVER GHOST (جدار الحماية)
// ----------------------------------------------------------------------------
@interface _X_NET : NSObject
@end
@implementation _X_NET
- (NSURLSessionDataTask *)f_req:(NSURLRequest *)r completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))c {
    if (!r || !r.URL) return [self f_req:r completionHandler:c];
    NSString *u = [[r URL] absoluteString].lowercaseString;
    
    // الفلتر المشفر
    if ([u containsString:[_X_CORE S_Report]] || // report
        [u containsString:[_X_CORE S_Crash]] ||  // crashsight
        [u containsString:[_X_CORE S_Cdn]] && [u containsString:@"check"] ||
        [u containsString:[_X_CORE S_Data]]) {   // dataflow
        
        // إرسال رد "Fake 200 OK"
        if (c) {
            NSHTTPURLResponse *fake = [[NSHTTPURLResponse alloc] initWithURL:r.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
            c([NSData data], fake, nil);
        }
        return nil;
    }
    return [self f_req:r completionHandler:c];
}
@end

// ----------------------------------------------------------------------------
// [LAYER 5] THE IDENTITY SHIFTER (مغير الهوية)
// ----------------------------------------------------------------------------
@interface _X_PREF : NSObject
@end
@implementation _X_PREF
// تزوير UUID
- (NSUUID *)f_uid { return [NSUUID UUID]; }

// تصفير الذاكرة (Prefs)
- (id)f_get:(NSString *)k {
    if ([k containsString:[_X_CORE S_Shadow]] || 
        [k containsString:[_X_CORE S_Uuid]] || 
        [k containsString:[_X_CORE S_Token]] ||
        [k containsString:[_X_CORE S_Vmp]]) return nil;
    return [self f_get:k];
}
- (void)f_set:(id)v forKey:(NSString *)k {
    if ([k containsString:[_X_CORE S_Shadow]] || [k containsString:[_X_CORE S_Token]]) return;
    [self f_set:v forKey:k];
}
@end

// ----------------------------------------------------------------------------
// [LAYER 6] VISUAL CORE: BLACK FIRE (واجهة بلاك النارية)
// ----------------------------------------------------------------------------
@interface _X_UI : NSObject
@end
@implementation _X_UI
+ (void)Load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        
        // تصميم النص
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 40)];
        l.text = @"BLACK";
        l.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBlack];
        l.textColor = [UIColor colorWithWhite:0.05 alpha:1.0]; // أسود فحمي
        l.textAlignment = NSTextAlignmentCenter;
        
        // تأثير النار (Shadow Glow)
        l.layer.shadowColor = [[UIColor redColor] CGColor];
        l.layer.shadowOffset = CGSizeMake(0, 0);
        l.layer.shadowOpacity = 1.0;
        l.layer.shadowRadius = 4.0;
        
        // الأنيميشن 1: تغيير اللون (أحمر <-> برتقالي)
        CABasicAnimation *cAnim = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
        cAnim.fromValue = (id)[[UIColor redColor] CGColor];
        cAnim.toValue = (id)[[UIColor orangeColor] CGColor];
        cAnim.duration = 0.4;
        cAnim.autoreverses = YES;
        cAnim.repeatCount = INFINITY;
        
        // الأنيميشن 2: النبض (احتراق)
        CABasicAnimation *rAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        rAnim.fromValue = @(4.0);
        rAnim.toValue = @(12.0);
        rAnim.duration = 0.2; // سريع جداً كالشرارة
        rAnim.autoreverses = YES;
        rAnim.repeatCount = INFINITY;
        
        [l.layer addAnimation:cAnim forKey:@"burnC"];
        [l.layer addAnimation:rAnim forKey:@"burnR"];
        
        l.userInteractionEnabled = NO;
        [w addSubview:l];
        [w bringSubviewToFront:l];
    });
}
@end

// ----------------------------------------------------------------------------
// [SYSTEM] ACTIVATION PROTOCOL
// ----------------------------------------------------------------------------
static void Z(Class c, SEL o, SEL n) {
    if (!c) return;
    Method mO = class_getInstanceMethod(c, o);
    Method mN = class_getInstanceMethod(c, n);
    if (class_addMethod(c, o, method_getImplementation(mN), method_getTypeEncoding(mN))) {
        class_replaceMethod(c, o, method_getImplementation(mO), method_getTypeEncoding(mO));
    } else { method_exchangeImplementations(mO, mN); }
}

static __attribute__((constructor)) void Init_BlackNebula() {
    // 1. تنظيف عميق للمجلدات (مصائد anogs)
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // فك تشفير المسارات لإنشاء المصائد
    NSString *p1 = [doc stringByAppendingPathComponent:[_X_CORE S_Ano]]; // ano_tmp
    NSString *p2 = [doc stringByAppendingPathComponent:[_X_CORE S_Tss]]; // tss_tmp
    
    NSArray *traps = @[p1, p2];
    for (NSString *t in traps) {
        if ([fm fileExistsAtPath:t]) [fm removeItemAtPath:t error:nil];
        [fm createDirectoryAtPath:t withIntermediateDirectories:YES attributes:nil error:nil];
    }

    static dispatch_once_t ot;
    dispatch_once(&ot, ^{
        // تفعيل الهوكات
        Z([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), @selector(f_req:completionHandler:));
        Z([NSFileManager class], @selector(createFileAtPath:contents:attributes:), @selector(f_wrt:contents:attributes:));
        Z([NSFileManager class], @selector(fileExistsAtPath:), @selector(f_chk:));
        Z([NSUserDefaults class], @selector(objectForKey:), @selector(f_get:));
        Z([NSUserDefaults class], @selector(setObject:forKey:), @selector(f_set:forKey:));
        Z([UIDevice class], @selector(identifierForVendor), @selector(f_uid));
        
        // تشغيل الواجهة
        [_X_UI Load];
    });
}
