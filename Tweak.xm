#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <dispatch/dispatch.h>

// ============================================================================
//  TITANIUM V17: FULL CIPHER & FRAMEWORK EDITION (NON-JB)
//  Strategy: Late Encryption + Dynamic Symbol Hunting
// ============================================================================

// --- 1. محرك فك التشفير (XOR Engine) ---
#define CIPHER_KEY 0x3F

void decrypt_string(char *str, size_t len) {
    for (size_t i = 0; i < len; i++) {
        str[i] ^= CIPHER_KEY;
    }
}

// --- 2. بدائل الدوال (Safe Replacements) ---
void* safe_return_null(void) { return NULL; }
void safe_return_void(void) { return; }

// --- 3. المحقن المشفر (Cipher Injector) ---
void Start_Integrated_Protection() {
    
    // مصفوفة تحتوي على أسماء الدوال مشفرة لكي لا تكتشفها اللعبة بالفحص النصي
    // سنستخدم dlsym للبحث عنها وقت التشغيل فقط
    
    // 1. "_AnoSDKGetReportData2"
    char s1[] = {0x60, 0x7E, 0x51, 0x50, 0x6C, 0x7B, 0x74, 0x78, 0x58, 0x54, 0x41, 0x6D, 0x54, 0x41, 0x50, 0x4D, 0x4B, 0x7B, 0x54, 0x43, 0x5E, 0x0D, 0x00};
    decrypt_string(s1, 22);
    
    // 2. "ACE_Init"
    char s2[] = {0x7E, 0x7C, 0x7A, 0x60, 0x76, 0x51, 0x56, 0x4B, 0x00};
    decrypt_string(s2, 8);
    
    const char* targets[] = {s1, s2};
    
    for (int i = 0; i < 2; i++) {
        void *addr = dlsym(RTLD_DEFAULT, targets[i]);
        if (addr != NULL) {
            MSHookFunction(addr, (void *)safe_return_null, NULL);
        }
    }
    
    NSLog(@"[Titanium] Integrated Protection Deployed.");
}

// --- 4. المحقن الرئيسي (Constructer with Safe Delay) ---
// استخدام constructor لضمان التحميل عند حقن الفريمورك
static __attribute__((constructor)) void startup() {
    // تأخير 10 ثوانٍ كاملة لضمان تخطي فحص الحماية الأولي واستقرار الفريمورك
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        Start_Integrated_Protection();
    });
}
