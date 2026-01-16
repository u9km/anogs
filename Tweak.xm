#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import <time.h>
#import <dlfcn.h>
#import <string.h>

// ============================================================================
//  TITANIUM GOD MODE: UNIVERSAL EDITION (ALL VERSIONS)
//  Supports: Global, KR, VN, TW, BGMI
//  Technique: Hybrid (Static Offsets + Dynamic Caller Check)
// ============================================================================

// --- 1. دوال مساعدة ذكية (Smart Helpers) ---

// دالة لفحص هل الاستدعاء قادم من مكتبة الحماية (anogs) أم من اللعبة؟
// هذه هي سر "دعم جميع النسخ" بدون كراش
bool is_caller_anogs() {
    void *return_addr = __builtin_return_address(0);
    Dl_info info;
    if (dladdr(return_addr, &info) && info.dli_fname) {
        // فحص إذا كان اسم الملف يحتوي على "ano" أو جزء من الحماية
        if (strstr(info.dli_fname, "ano") || strstr(info.dli_fname, "AnoSDK")) {
            return true; // نعم، الحماية هي من تطلب، يجب الحظر!
        }
    }
    return false;
}

uint64_t get_real_address(uint64_t offset) {
    return _dyld_get_image_vmaddr_slide(0) + offset;
}

// --- 2. هوك النظام العام (Universal System Hooks) ---
// هذه الدوال تعمل على أي إصدار لأنها جزء من نظام iOS

// منع الكراش العام (Abort/Exit)
void (*old_abort)(void);
void new_abort(void) {
    if (is_caller_anogs()) {
        // إذا الحماية حاولت عمل كراش -> تجاهل
        return;
    }
    old_abort();
}

// منع فحص النظام (Sysctl)
int (*old_sysctl)(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
int new_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (is_caller_anogs()) {
        // إذا الحماية طلبت معلومات الجهاز -> ارجع خطأ (غير موجود)
        return -1; 
    }
    return old_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
}

// منع الاتصال (Socket/Connect)
int (*old_connect)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int new_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (is_caller_anogs()) {
        // إذا الحماية حاولت الاتصال بالسيرفر -> اقطع الخط
        return -1;
    }
    return old_connect(sockfd, addr, addrlen);
}

// --- 3. دوال الأوفست (Static Helpers) ---
void null_void(void) { return; }
int return_zero(void) { return 0; }
void* return_null_ptr(void) { return NULL; }

// حماية السرعة
uint64_t (*old_mach_time)(void);
uint64_t new_mach_time(void) { return old_mach_time(); }

// رموز البيانات السريعة
extern "C" void* _AnoSDKGetReportData2();
extern "C" void* _AnoSDKGetReportData3();
extern "C" void* _AnoSDKGetReportData4();

// --- 4. المحقن الرئيسي (Main Constructor) ---

%ctor {
    NSLog(@"[Titanium] Injecting Universal God Mode...");

    // =========================================================
    // PART A: DYNAMIC PROTECTION (لكل النسخ والتحديثات)
    // =========================================================
    // نستخدم هذا لضمان العمل حتى لو تغيرت الأوفستات
    
    MSHookFunction((void *)abort, (void *)new_abort, (void **)&old_abort);
    MSHookFunction((void *)sysctl, (void *)new_sysctl, (void **)&old_sysctl);
    MSHookFunction((void *)connect, (void *)new_connect, (void **)&old_connect);
    MSHookFunction((void *)mach_absolute_time, (void *)new_mach_time, (void **)&old_mach_time);

    // =========================================================
    // PART B: SURGICAL OFFSETS (مستخرجة من ملفك - للحصول على أقصى أداء)
    // =========================================================
    // ملاحظة: هذه الأوفستات دقيقة لنسختك الحالية، وتعمل جنباً إلى جنب مع الحماية الديناميكية
    
    // 1. Anti-Crash
    MSHookFunction((void *)get_real_address(0x82FBC), (void *)null_void, NULL); // [TCJ]Abort
    MSHookFunction((void *)get_real_address(0x30028), (void *)null_void, NULL); // sfc_crash
    MSHookFunction((void *)get_real_address(0x79930), (void *)null_void, NULL); // crash
    
    // 2. Heartbeat & Server
    MSHookFunction((void *)get_real_address(0x447B0), (void *)return_zero, NULL); // HBCheck
    MSHookFunction((void *)get_real_address(0x2ED6C), (void *)return_zero, NULL); // CONNECTOR

    // 3. Combat (Magic/Bullet)
    MSHookFunction((void *)get_real_address(0x815C4), (void *)null_void, NULL); // tcj_protect
    MSHookFunction((void *)get_real_address(0x7B2A8), (void *)null_void, NULL); // sc_protect

    // 4. System & Init
    MSHookFunction((void *)get_real_address(0x10C24), (void *)return_zero, NULL); // Sysctl Ptr
    MSHookFunction((void *)get_real_address(0x2D69C), (void *)null_void, NULL); // Init
    MSHookFunction((void *)get_real_address(0x2D92C), (void *)null_void, NULL); // UserInfo

    // 5. Anti-Report & Data
    MSHookFunction((void *)get_real_address(0x3667C), (void *)null_void, NULL); // REPORT
    MSHookFunction((void *)get_real_address(0x371E0), (void *)null_void, NULL); // COREREPORT
    MSHookFunction((void *)get_real_address(0x2DD2C), (void *)null_void, NULL); // DelReport
    MSHookFunction((void *)get_real_address(0x102D48), (void *)null_void, NULL); // ms_data_crc
    
    // 6. Quick Data Exports (رموز عامة تعمل في كل النسخ)
    MSHookFunction((void *)_AnoSDKGetReportData2, (void *)return_null_ptr, NULL);
    MSHookFunction((void *)_AnoSDKGetReportData3, (void *)return_null_ptr, NULL);
    MSHookFunction((void *)_AnoSDKGetReportData4, (void *)return_null_ptr, NULL);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "_AnoSDKDelReportData3"), (void *)null_void, NULL);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "_AnoSDKDelReportData4"), (void *)null_void, NULL);
    
    // 7. Data Parsers
    MSHookFunction((void *)get_real_address(0x172DC0), (void *)return_null_ptr, NULL); // ComData
    MSHookFunction((void *)get_real_address(0x1007FC), (void *)return_null_ptr, NULL); // AntiDataProxy
    MSHookFunction((void *)get_real_address(0x173BF0), (void *)return_null_ptr, NULL); // PointDataMgr

    NSLog(@"[Titanium] Universal God Mode ACTIVATED.");
}
