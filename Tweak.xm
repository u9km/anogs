#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import <time.h>
#import <dlfcn.h>
#import <string.h>

// --- [تصحيح الخطأ] ---
// تمت إضافة هذه المكتبات لحل مشكلة socklen_t و connect
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

// ============================================================================
//  TITANIUM GOD MODE: UNIVERSAL EDITION (FIXED)
// ============================================================================

// --- 1. Smart Helpers ---

bool is_caller_anogs() {
    void *return_addr = __builtin_return_address(0);
    Dl_info info;
    if (dladdr(return_addr, &info) && info.dli_fname) {
        if (strstr(info.dli_fname, "ano") || strstr(info.dli_fname, "AnoSDK")) {
            return true;
        }
    }
    return false;
}

uint64_t get_real_address(uint64_t offset) {
    return _dyld_get_image_vmaddr_slide(0) + offset;
}

// --- 2. Universal System Hooks ---

// Abort Hook
void (*old_abort)(void);
void new_abort(void) {
    if (is_caller_anogs()) return;
    old_abort();
}

// Sysctl Hook
int (*old_sysctl)(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
int new_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (is_caller_anogs()) return -1; 
    return old_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
}

// Connect Hook (Socket Fix)
int (*old_connect)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int new_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (is_caller_anogs()) return -1;
    return old_connect(sockfd, addr, addrlen);
}

// --- 3. Static Helpers ---
void null_void(void) { return; }
int return_zero(void) { return 0; }
void* return_null_ptr(void) { return NULL; }

// Speed Hook
uint64_t (*old_mach_time)(void);
uint64_t new_mach_time(void) { return old_mach_time(); }

// Quick Data Symbols
extern "C" void* _AnoSDKGetReportData2();
extern "C" void* _AnoSDKGetReportData3();
extern "C" void* _AnoSDKGetReportData4();

// --- 4. Main Constructor ---

%ctor {
    NSLog(@"[Titanium] Injecting Universal God Mode...");

    // Part A: Dynamic Hooks
    MSHookFunction((void *)abort, (void *)new_abort, (void **)&old_abort);
    MSHookFunction((void *)sysctl, (void *)new_sysctl, (void **)&old_sysctl);
    
    // تم إصلاح Connect الآن بعد إضافة المكتبة
    MSHookFunction((void *)connect, (void *)new_connect, (void **)&old_connect);
    MSHookFunction((void *)mach_absolute_time, (void *)new_mach_time, (void **)&old_mach_time);

    // Part B: Static Offsets
    // Anti-Crash
    MSHookFunction((void *)get_real_address(0x82FBC), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x30028), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x79930), (void *)null_void, NULL);
    
    // Heartbeat
    MSHookFunction((void *)get_real_address(0x447B0), (void *)return_zero, NULL);
    MSHookFunction((void *)get_real_address(0x2ED6C), (void *)return_zero, NULL);

    // Combat
    MSHookFunction((void *)get_real_address(0x815C4), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x7B2A8), (void *)null_void, NULL);

    // System
    MSHookFunction((void *)get_real_address(0x10C24), (void *)return_zero, NULL);
    MSHookFunction((void *)get_real_address(0x2D69C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x2D92C), (void *)null_void, NULL);

    // Anti-Report & Data
    MSHookFunction((void *)get_real_address(0x3667C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x371E0), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x2DD2C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x102D48), (void *)null_void, NULL);
    
    // Quick Data
    MSHookFunction((void *)_AnoSDKGetReportData2, (void *)return_null_ptr, NULL);
    MSHookFunction((void *)_AnoSDKGetReportData3, (void *)return_null_ptr, NULL);
    MSHookFunction((void *)_AnoSDKGetReportData4, (void *)return_null_ptr, NULL);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "_AnoSDKDelReportData3"), (void *)null_void, NULL);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "_AnoSDKDelReportData4"), (void *)null_void, NULL);
    
    // Data Parsers
    MSHookFunction((void *)get_real_address(0x172DC0), (void *)return_null_ptr, NULL);
    MSHookFunction((void *)get_real_address(0x1007FC), (void *)return_null_ptr, NULL);
    MSHookFunction((void *)get_real_address(0x173BF0), (void *)return_null_ptr, NULL);

    NSLog(@"[Titanium] Universal God Mode ACTIVATED.");
}
