#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>

#define _V_STR id
#define _V_DAT id
#define _V_REQ id
#define _V_SES id
#define _V_MAN id
#define _V_DEF id
#define _V_BUN id
#define _V_LBL id
#define _V_WIN id
#define _V_ANI id
#define _V_CLR id

#define _C_CRYPT    _0xFA
#define _C_SOVEREIGN _0xFB
#define _C_VISUAL   _0xFC

#define _M_DEC      m01
#define _M_CHK      m02
#define _M_WRT      m03
#define _M_REQ      m04
#define _M_UID      m05
#define _M_GET      m06
#define _M_SET      m07
#define _M_BID      m08
#define _M_PFR      m09

#define _KEY        0xE2 // مفتاح تشفير سيادي جديد

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

// تشفير البيانات الحساسة المكتشفة في سجلات الشهادة
+ (_V_STR)s1 { return [self _M_DEC:@"\x91\x9A\x93\x96\x9D\x85\xAC\x80\x93\x9F\x97\x89\x80"]; } // ShadowTracker
+ (_V_STR)s2 { return [self _M_DEC:@"\x83\x8C\x8D\xAD\x96\x8F\x92"]; }               // ano_tmp
+ (_V_STR)s3 { return [self _M_DEC:@"\x96\x91\x91\xAD\x96\x8F\x92"]; }               // tss_tmp
+ (_V_STR)s4 { return [self _M_DEC:@"\x81\x8D\x8F\x9C\x96\x87\x8C\x81\x87\x8C\x96\x9C\x8B\x85"]; } // com.tencent.ig
+ (_V_STR)s5 { return [self _M_DEC:@"\x87\x8F\x80\x87\x86\x86\x87\x86"]; }           // embedded
+ (_V_STR)s6 { return [self _M_DEC:@"\x8F\x8D\x80\x8B\x8E\x87\x92\x90\x8D\x94\x8B\x91\x8B\x87\x86"]; } // mobileprovision
+ (_V_STR)s7 { return [self _M_DEC:@"\x90\x87\x92\x8D\x90\x96"]; }               // report
+ (_V_STR)s8 { return [self _M_DEC:@"\x81\x90\x83\x91\x8A\x91\x8B\x85\x8A\x96"]; }     // crashsight
+ (_V_STR)ui { return [self _M_DEC:@"\x80\x8E\x83\x81\x89"]; }                       // BLACK
@end

@interface _C_SOVEREIGN : NSObject
@end
@implementation _C_SOVEREIGN

// 1. حماية الشهادة (The Sovereign Shield)
// تزوير الهوية وإخفاء ملف التوقيع تماماً
- (NSString *)x_bid { return [_C_CRYPT s4]; }

- (NSString *)x_pfr:(NSString *)n ofType:(NSString *)t {
    if ([n isEqualToString:[_C_CRYPT s5]] && [t isEqualToString:[_C_CRYPT s6]]) {
        return nil; // إرجاع "لا يوجد ملف شهادة"
    }
    return [self x_pfr:n ofType:t];
}

// 2. حماية النزاهة (Integrity Fix)
- (BOOL)x_wrt:(NSString *)p contents:(NSData *)d attributes:(id)a {
    if ([p containsString:[_C_CRYPT s2]] || [p containsString:[_C_CRYPT s3]]) return YES;
    return [self x_wrt:p contents:d attributes:a];
}

- (BOOL)x_chk:(NSString *)p {
    if ([p containsString:[_C_CRYPT s2]] || [p containsString:[_C_CRYPT s3]] || [p containsString:[_C_CRYPT s6]]) return NO;
    return [self x_chk:p];
}

// 3. عزل البلاغات (Network Isolation)
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
@end

@interface _C_VISUAL : NSObject
@end
@implementation _C_VISUAL
+ (void)Ignite {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, 45)];
        l.text = [[_C_CRYPT ui] uppercaseString];
        l.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBlack];
        l.textColor = [UIColor colorWithWhite:0.05 alpha:1.0];
        l.textAlignment = NSTextAlignmentCenter;
        l.layer.shadowColor = [[UIColor redColor] CGColor];
        l.layer.shadowOpacity = 1.0;
        l.layer.shadowRadius = 8.0;
        
        CABasicAnimation *f = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        f.fromValue = @(3.0); f.toValue = @(16.0); f.duration = 0.4;
        f.autoreverses = YES; f.repeatCount = INFINITY;
        [l.layer addAnimation:f forKey:@"burn"];
        
        [w addSubview:l];
        [w bringSubviewToFront:l];
    });
}
@end

static void H(Class c, SEL o, SEL n) {
    Method mO = class_getInstanceMethod(c, o);
    Method mN = class_getInstanceMethod(c, n);
    method_exchangeImplementations(mO, mN);
}

static __attribute__((constructor)) void Init_Sovereign() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // تصفير ملفات الباند الغيابي
    NSArray *traps = @[[doc stringByAppendingPathComponent:[_C_CRYPT s2]], [doc stringByAppendingPathComponent:[_C_CRYPT s3]]];
    for (NSString *t in traps) {
        if ([fm fileExistsAtPath:t]) [fm removeItemAtPath:t error:nil];
        [fm createDirectoryAtPath:t withIntermediateDirectories:YES attributes:nil error:nil];
    }

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // تفعيل الحماية السيادية
        H([NSBundle class], @selector(bundleIdentifier), @selector(x_bid));
        H([NSBundle class], @selector(pathForResource:ofType:), @selector(x_pfr:ofType:));
        H([NSFileManager class], @selector(createFileAtPath:contents:attributes:), @selector(x_wrt:contents:attributes:));
        H([NSFileManager class], @selector(fileExistsAtPath:), @selector(x_chk:));
        H([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), @selector(x_req:completionHandler:));
        H([UIDevice class], @selector(identifierForVendor), @selector(identifierForVendor)); // الحفاظ على هوية ثابتة برمجياً
        
        [_C_VISUAL Ignite];
    });
}
