#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/sysctl.h>
#import <sys/ptrace.h>
#import <dlfcn.h>

// ============================================================================
//  PROJECT: TITANIUM BLACK [v12.0 FINAL]
//  Features: Anti-Debug, Anti-Crack, Anti-Report, Persistence Kill
//  Security: Kernel-Level Stealth + Full XOR Cipher
// ============================================================================

#define _V_STR id
#define _V_DAT id
#define _V_REQ id
#define _V_SES id
#define _V_MAN id
#define _V_DEF id
#define _V_BUN id

#define _C_CRYPT    _0xCC
#define _C_ARMOR    _0xDD
#define _C_UI       _0xEE

#define _KEY        0x33 // مفتاح تشفير تيتانيوم الجديد

@interface _C_CRYPT : NSObject
@end
@implementation _C_CRYPT
+ (NSString *)_M_DEC:(NSString *)i {
    if (!i) return nil;
    const char *c = [i UTF8String];
    NSMutableString *s = [NSMutableString string];
    for (int x = 0; x < [i length]; x++) {
        [s appendFormat:@"%c", c[x] ^ _KEY];
    }
    return s;
}

// تشفير كافة البيانات السيادية
+ (_V_STR)s1 { return [self _M_DEC:@"\x60\x5B\x52\x57\x5C\x44\x67\x41\x52\x50\x58\x46\x41"]; } // ShadowTracker
+ (_V_STR)s2 { return [self _M_DEC:@"\x52\x5D\x5C\x6C\x47\x5E\x43"]; }               // ano_tmp
+ (_V_STR)s3 { return [self _M_DEC:@"\x47\x40\x40\x6C\x47\x5E\x43"]; }               // tss_tmp
+ (_V_STR)s4 { return [self _M_DEC:@"\x50\x5C\x5E\x1D\x47\x56\x5D\x50\x56\x5D\x47\x1D\x5A\x54"]; } // com.tencent.ig
+ (_V_STR)s5 { return [self _M_DEC:@"\x56\x5E\x51\x56\x57\x57\x56\x57"]; }           // embedded
+ (_V_STR)s6 { return [self _M_DEC:@"\x5E\x5C\x51\x5A\x5F\x56\x43\x41\x5C\x47\x5A\x52\x5A\x56\x57"]; } // mobileprovision
+ (_V_STR)s7 { return [self _M_DEC:@"\x41\x56\x43\x5C\x41\x47"]; }               // report
+ (_V_STR)s8 { return [self _M_DEC:@"\x50\x41\x52\x40\x5B\x40\x5A\x54\x5B\x47"]; }     // crashsight
+ (_V_STR)ui { return [self _M_DEC:@"\x11\x1F\x12\x10\x18"]; }                       // BLACK
@end

@interface _C_ARMOR : NSObject
@end
@implementation _C_ARMOR

// 1. حماية الشهادة والكراك
- (NSString *)x_bid { return [_C_CRYPT s4]; }
- (NSString *)x_pfr:(NSString *)n ofType:(NSString *)t {
    if ([n isEqualToString:[_C_CRYPT s5]] && [t isEqualToString:[_C_CRYPT s6]]) return nil;
    return [self x_pfr:n ofType:t];
}

// 2. قتل البصمة الدائمة (الباند الغيابي)
- (BOOL)x_wrt:(NSString *)p contents:(NSData *)d attributes:(id)a {
    if ([p containsString:[_C_CRYPT s2]] || [p containsString:[_C_CRYPT s3]]) return YES;
    return [self x_wrt:p contents:d attributes:a];
}
- (BOOL)x_chk:(NSString *)p {
    if ([p containsString:[_C_CRYPT s2]] || [p containsString:[_C_CRYPT s3]] || [p containsString:[_C_CRYPT s6]]) return NO;
    return [self x_chk:p];
}

// 3. عزل الشبكة وحماية الايمبوت
- (id)x_req:(id)r completionHandler:(void (^)(id, id, id))c {
    NSString *u = [[(NSURLRequest *)r URL] absoluteString].lowercaseString;
    if ([u containsString:[_C_CRYPT s7]] || [u containsString:[_C_CRYPT s8]]) {
        if (c) {
            id fakeRes = [[NSHTTPURLResponse alloc] initWithURL:[(NSURLRequest *)r URL] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
            c([NSData data], fakeRes, nil);
        }
        return nil;
    }
    return [self x_req:r completionHandler:c];
}

// 4. الحماية ضد التصحيح (Anti-Debug)
+ (void)Defend {
    // منع الاتصال بالعملية (ptrace)
    ptrace(PT_DENY_ATTACH, 0, 0, 0);
    
    // فحص وجود مصحح نشط (sysctl)
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == 0) {
        if (info.kp_proc.p_flag & P_TRACED) {
            exit(0); // الخروج فوراً إذا تم اكتشاف تصحيح
        }
    }
}
@end



@interface _C_UI : NSObject
@end
@implementation _C_UI
+ (void)Show {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, 45)];
        l.text = [[_C_CRYPT ui] uppercaseString];
        l.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBlack];
        l.textColor = [UIColor colorWithWhite:0.04 alpha:1.0];
        l.textAlignment = NSTextAlignmentCenter;
        l.layer.shadowColor = [[UIColor redColor] CGColor];
        l.layer.shadowOpacity = 1.0;
        l.layer.shadowRadius = 12.0;
        
        CABasicAnimation *f = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        f.fromValue = @(4.0); f.toValue = @(20.0); f.duration = 0.45;
        f.autoreverses = YES; f.repeatCount = INFINITY;
        [l.layer addAnimation:f forKey:@"titanium"];
        
        [w addSubview:l]; [w bringSubviewToFront:l];
    });
}
@end

static void H(Class c, SEL o, SEL n) {
    Method mO = class_getInstanceMethod(c, o);
    Method mN = class_getInstanceMethod(c, n);
    method_exchangeImplementations(mO, mN);
}

static __attribute__((constructor)) void Init_Titanium() {
    // تفعيل الحماية ضد التصحيح فوراً
    [_C_ARMOR Defend];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *traps = @[[doc stringByAppendingPathComponent:[_C_CRYPT s2]], [doc stringByAppendingPathComponent:[_C_CRYPT s3]]];
    for (NSString *t in traps) {
        if ([fm fileExistsAtPath:t]) [fm removeItemAtPath:t error:nil];
        [fm createDirectoryAtPath:t withIntermediateDirectories:YES attributes:nil error:nil];
    }

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        H([NSBundle class], @selector(bundleIdentifier), @selector(x_bid));
        H([NSBundle class], @selector(pathForResource:ofType:), @selector(x_pfr:ofType:));
        H([NSFileManager class], @selector(createFileAtPath:contents:attributes:), @selector(x_wrt:contents:attributes:));
        H([NSFileManager class], @selector(fileExistsAtPath:), @selector(x_chk:));
        H([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), @selector(x_req:completionHandler:));
        
        [_C_UI Show];
    });
}
