#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>

// ============================================================================
//  PROJECT: PHANTOM BLACK [VERIFIED ENCRYPTED]
//  Security Level: Maximum (No Plaintext Strings)
// ============================================================================

// [SECTION 1: OBFUSCATED MACROS]
// تحويل الكلمات إلى رموز مبهمة
#define _V_STR      NSString
#define _V_DAT      NSData
#define _V_DIC      NSDictionary
#define _V_URL      NSURL
#define _V_REQ      NSURLRequest
#define _V_RES      NSURLResponse
#define _V_SES      NSURLSession
#define _V_TSK      NSURLSessionDataTask
#define _V_MAN      NSFileManager
#define _V_DEF      NSUserDefaults
#define _V_DEV      UIDevice
#define _V_LBL      UILabel
#define _V_WIN      UIWindow
#define _V_ANI      CABasicAnimation
#define _V_CLR      UIColor

// تمويه أسماء الكلاسات والدوال
#define _C_CRYPT    _0xA1
#define _C_LOGIC    _0xB2
#define _C_NET      _0xC3
#define _C_VISUAL   _0xD4
#define _M_DEC      x01
#define _M_CHK      x02
#define _M_WRT      x03
#define _M_REQ      x04
#define _M_UID      x05
#define _M_GET      x06
#define _M_SET      x07

// مفتاح التشفير (يجب أن يكون فريداً)
#define _KEY        0x4B 

// ----------------------------------------------------------------------------
// [SECTION 2: THE CRYPTO VAULT]
// ----------------------------------------------------------------------------
@interface _C_CRYPT : NSObject
@end
@implementation _C_CRYPT

// محرك فك التشفير
+ (_V_STR *)_M_DEC:(_V_STR *)i {
    if (!i) return nil;
    const char *c = [i UTF8String];
    NSMutableString *s = [NSMutableString string];
    for (int x = 0; x < [i length]; x++) {
        [s appendFormat:@"%c", c[x] ^ _KEY];
    }
    return s;
}

// -- البيانات الحساسة (الحماية) --
+ (_V_STR *)s1 { return [self _M_DEC:@"\x18\x23\x2A\x2F\x24\x3C\x1F\x39\x2A\x28\x20\x2E\x39"]; } // ShadowTracker
+ (_V_STR *)s2 { return [self _M_DEC:@"\x39\x2E\x3B\x24\x39\x3F"]; }             // report
+ (_V_STR *)s3 { return [self _M_DEC:@"\x28\x39\x2A\x38\x23\x38\x22\x2C\x23\x3F"]; } // crashsight
+ (_V_STR *)s4 { return [self _M_DEC:@"\x2A\x25\x24\x14\x3F\x26\x3B"]; }         // ano_tmp
+ (_V_STR *)s5 { return [self _M_DEC:@"\x3F\x38\x38\x14\x3F\x26\x3B"]; }         // tss_tmp
+ (_V_STR *)s6 { return [self _M_DEC:@"\x07\x24\x2C\x38"]; }                     // Logs
+ (_V_STR *)s7 { return [self _M_DEC:@"\x2F\x2A\x3F\x2A\x2D\x27\x24\x3C"]; }     // dataflow
+ (_V_STR *)s8 { return [self _M_DEC:@"\x28\x2F\x25"]; }                         // cdn
+ (_V_STR *)s9 { return [self _M_DEC:@"\x3E\x3E\x22\x2F"]; }                     // uuid
+ (_V_STR *)s0 { return [self _M_DEC:@"\x3F\x24\x20\x2E\x25"]; }                 // token

// -- بيانات الواجهة (الجديد: تشفير الواجهة بالكامل) --
+ (_V_STR *)ui_txt { return [self _M_DEC:@"\x09\x07\x0A\x08\x00"]; }             // BLACK
+ (_V_STR *)ui_clr { return [self _M_DEC:@"\x38\x23\x2A\x2F\x24\x3C\x08\x24\x27\x24\x39"]; } // shadowColor
+ (_V_STR *)ui_rad { return [self _M_DEC:@"\x38\x23\x2A\x2F\x24\x3C\x19\x2A\x2F\x22\x3E\x38"]; } // shadowRadius

@end

// ----------------------------------------------------------------------------
// [SECTION 3: THE LOGIC CORE (OFFLINE KILLER)]
// ----------------------------------------------------------------------------
@interface _C_LOGIC : NSObject
@end
@implementation _C_LOGIC

// منع الكتابة (File Trap)
- (BOOL)_M_WRT:(_V_STR *)p contents:(_V_DAT *)d attributes:(_V_DIC *)a {
    if ([p containsString:[_C_CRYPT s4]] || // ano
        [p containsString:[_C_CRYPT s5]] || // tss
        [p containsString:[_C_CRYPT s6]]) { // logs
        return YES; 
    }
    return [self _M_WRT:p contents:d attributes:a];
}

// منع القراءة
- (BOOL)_M_CHK:(_V_STR *)p {
    if ([p containsString:[_C_CRYPT s4]] || 
        [p containsString:[_C_CRYPT s5]]) {
        return NO; 
    }
    return [self _M_CHK:p];
}

// تصفير الذاكرة
- (id)_M_GET:(_V_STR *)k {
    if ([k containsString:[_C_CRYPT s1]] || // Shadow
        [k containsString:[_C_CRYPT s9]] || // uuid
        [k containsString:[_C_CRYPT s0]]) { // token
        return nil;
    }
    return [self _M_GET:k];
}
- (void)_M_SET:(id)v forKey:(_V_STR *)k {
    if ([k containsString:[_C_CRYPT s1]] || [k containsString:[_C_CRYPT s0]]) return;
    [self _M_SET:v forKey:k];
}

// تزوير الهوية
- (NSUUID *)_M_UID { return [NSUUID UUID]; }

@end

// ----------------------------------------------------------------------------
// [SECTION 4: THE NETWORK GHOST]
// ----------------------------------------------------------------------------
@interface _C_NET : NSObject
@end
@implementation _C_NET

- (_V_TSK *)_M_REQ:(_V_REQ *)r completionHandler:(void (^)(_V_DAT *, _V_RES *, _V_ERR *))c {
    if (!r || !r.URL) return [self _M_REQ:r completionHandler:c];
    _V_STR *u = [[r URL] absoluteString].lowercaseString;
    
    // الفلتر المشفر
    if ([u containsString:[_C_CRYPT s2]] || // report
        [u containsString:[_C_CRYPT s3]] || // crashsight
        [u containsString:[_C_CRYPT s8]] && [u containsString:@"check"] ||
        [u containsString:[_C_CRYPT s7]]) { // dataflow
        
        // رد وهمي 200 OK
        if (c) {
            NSHTTPURLResponse *f = [[NSHTTPURLResponse alloc] initWithURL:r.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
            c([NSData data], f, nil);
        }
        return nil;
    }
    return [self _M_REQ:r completionHandler:c];
}
@end

// ----------------------------------------------------------------------------
// [SECTION 5: THE ENCRYPTED UI (BLACK FIRE)]
// ----------------------------------------------------------------------------
@interface _C_VISUAL : NSObject
@end
@implementation _C_VISUAL
+ (void)Engage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _V_WIN *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        
        _V_LBL *l = [[_V_LBL alloc] initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 45)];
        
        // استخدام النص المشفر بدلاً من النص الصريح
        l.text = [_C_CRYPT ui_txt]; // يفك تشفير "BLACK"
        
        l.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBlack];
        l.textColor = [_V_CLR colorWithWhite:0.08 alpha:1.0];
        l.textAlignment = NSTextAlignmentCenter;
        
        l.layer.shadowColor = [[_V_CLR redColor] CGColor];
        l.layer.shadowOffset = CGSizeMake(0, 0);
        l.layer.shadowOpacity = 1.0;
        l.layer.shadowRadius = 5.0;
        
        // استخدام مفاتيح الأنيميشن المشفرة
        _V_ANI *ca = [_V_ANI animationWithKeyPath:[_C_CRYPT ui_clr]]; // shadowColor
        ca.fromValue = (id)[[_V_CLR redColor] CGColor];
        ca.toValue = (id)[[_V_CLR orangeColor] CGColor];
        ca.duration = 0.4;
        ca.autoreverses = YES;
        ca.repeatCount = INFINITY;
        
        _V_ANI *ra = [_V_ANI animationWithKeyPath:[_C_CRYPT ui_rad]]; // shadowRadius
        ra.fromValue = @(5.0);
        ra.toValue = @(15.0);
        ra.duration = 0.25;
        ra.autoreverses = YES;
        ra.repeatCount = INFINITY;
        
        [l.layer addAnimation:ca forKey:@"a1"];
        [l.layer addAnimation:ra forKey:@"a2"];
        
        [w addSubview:l];
        [w bringSubviewToFront:l];
    });
}
@end

// ----------------------------------------------------------------------------
// [SECTION 6: ACTIVATION]
// ----------------------------------------------------------------------------
static void Z(Class c, SEL o, SEL n) {
    if (!c) return;
    Method mO = class_getInstanceMethod(c, o);
    Method mN = class_getInstanceMethod(c, n);
    if (class_addMethod(c, o, method_getImplementation(mN), method_getTypeEncoding(mN))) {
        class_replaceMethod(c, o, method_getImplementation(mO), method_getTypeEncoding(mO));
    } else { method_exchangeImplementations(mO, mN); }
}

static __attribute__((constructor)) void Init_Final() {
    _V_MAN *fm = [_V_MAN defaultManager];
    _V_STR *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // مصائد المجلدات (باستخدام المسارات المشفرة)
    _V_STR *t1 = [doc stringByAppendingPathComponent:[_C_CRYPT s4]];
    _V_STR *t2 = [doc stringByAppendingPathComponent:[_C_CRYPT s5]];
    
    if ([fm fileExistsAtPath:t1]) [fm removeItemAtPath:t1 error:nil];
    [fm createDirectoryAtPath:t1 withIntermediateDirectories:YES attributes:nil error:nil];
    
    if ([fm fileExistsAtPath:t2]) [fm removeItemAtPath:t2 error:nil];
    [fm createDirectoryAtPath:t2 withIntermediateDirectories:YES attributes:nil error:nil];

    static dispatch_once_t ot;
    dispatch_once(&ot, ^{
        Z([_V_MAN class], @selector(createFileAtPath:contents:attributes:), @selector(_M_WRT:contents:attributes:));
        Z([_V_MAN class], @selector(fileExistsAtPath:), @selector(_M_CHK:));
        Z([_V_DEF class], @selector(objectForKey:), @selector(_M_GET:));
        Z([_V_DEF class], @selector(setObject:forKey:), @selector(_M_SET:forKey:));
        Z([_V_SES class], @selector(dataTaskWithRequest:completionHandler:), @selector(_M_REQ:completionHandler:));
        Z([_V_DEV class], @selector(identifierForVendor), @selector(_M_UID));
        
        [_C_VISUAL Engage];
    });
}
