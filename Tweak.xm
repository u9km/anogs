#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import <time.h>
#import <dlfcn.h>
#import <string.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

// ============================================================================
//  TITANIUM GOD MODE: UNIVERSAL EDITION (LINKER FIXED)
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

void (*old_abort)(void);
void new_abort(void) {
    if (is_caller_anogs()) return;
    old_abort();
}

int (*old_sysctl)(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
int new_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (is_caller_anogs()) return -1; 
    return old_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
}

int (*old_connect)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int new_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (is_caller_anogs()) return -1;
    return old_connect(sockfd, addr, addrlen);
}

// --- 3. Static Helpers ---
void null_void(void) { return; }
int return_zero(void) { return 0; }
void* return_null_ptr(void) { return NULL; }

uint64_t (*old_mach_time)(void);
uint64_t new_mach_time(void) { return old_mach_time(); }

// --- 4. Main Constructor ---

%ctor {
    NSLog(@"[Titanium] Injecting Universal God Mode...");

    // Part A: Dynamic System Hooks
    MSHookFunction((void *)abort, (void *)new_abort, (void **)&old_abort);
    MSHookFunction((void *)sysctl, (void *)new_sysctl, (void **)&old_sysctl);
    MSHookFunction((void *)connect, (void *)new_connect, (void **)&old_connect);
    MSHookFunction((void *)mach_absolute_time, (void *)new_mach_time, (void **)&old_mach_time);

    // Part B: Static Offsets (Your File Specific)
    MSHookFunction((void *)get_real_address(0x82FBC), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x30028), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x79930), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x447B0), (void *)return_zero, NULL);
    MSHookFunction((void *)get_real_address(0x2ED6C), (void *)return_zero, NULL);
    MSHookFunction((void *)get_real_address(0x815C4), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x7B2A8), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x10C24), (void *)return_zero, NULL);
    MSHookFunction((void *)get_real_address(0x2D69C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x2D92C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x3667C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x371E0), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x2DD2C), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x102D48), (void *)null_void, NULL);
    MSHookFunction((void *)get_real_address(0x172DC0), (void *)return_null_ptr, NULL);
    MSHookFunction((void *)get_real_address(0x1007FC), (void *)return_null_ptr, NULL);
    MSHookFunction((void *)get_real_address(0x173BF0), (void *)return_null_ptr, NULL);

    // Part C: Quick Data (FIXED LINKER ISSUE)
    // هنا قمنا بإزالة extern واستخدمنا dlsym للبحث عن الدالة وقت التشغيل فقط
    // هذا يمنع خطأ Linker Error 100%
    
    void *sym_get2 = dlsym(RTLD_DEFAULT, "_AnoSDKGetReportData2");
    if (sym_get2) MSHookFunction(sym_get2, (void *)return_null_ptr, NULL);

    void *sym_get3 = dlsym(RTLD_DEFAULT, "_AnoSDKGetReportData3");
    if (sym_get3) MSHookFunction(sym_get3, (void *)return_null_ptr, NULL);
    
    void *sym_get4 = dlsym(RTLD_DEFAULT, "_AnoSDKGetReportData4");
    if (sym_get4) MSHookFunction(sym_get4, (void *)return_null_ptr, NULL);
    
    void *sym_del3 = dlsym(RTLD_DEFAULT, "_AnoSDKDelReportData3");
    if (sym_del3) MSHookFunction(sym_del3, (void *)null_void, NULL);

    void *sym_del4 = dlsym(RTLD_DEFAULT, "_AnoSDKDelReportData4");
    if (sym_del4) MSHookFunction(sym_del4, (void *)null_void, NULL);

    NSLog(@"[Titanium] Universal God Mode ACTIVATED.");
}
