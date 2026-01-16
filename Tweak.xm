#import "fishhook.h"
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <sys/socket.h>
#import <netdb.h>
#import <dispatch/dispatch.h>

// --- إعدادات التشفير (XOR) ---
#define XOR_KEY 0x5A

void xor_crypt(char *str, size_t len) {
    for (size_t i = 0; i < len; i++) {
        str[i] ^= XOR_KEY;
    }
}

// --- نظام فحص مصدر الاستدعاء ---
bool is_untrusted_caller() {
    void *return_addr = __builtin_return_address(0);
    Dl_info info;
    if (dladdr(return_addr, &info) && info.dli_fname) {
        // تشفير "anogs" -> (Key 0x5A)
        char target[] = {0x3B, 0x34, 0x35, 0x3D, 0x29, 0x00};
        xor_crypt(target, 5);
        if (strstr(info.dli_fname, target)) return true;
    }
    return false;
}

// --- تعريف الدوال الأصلية للهوك الشبحي (Fishhook) ---
static int (*orig_connect)(int, const struct sockaddr *, socklen_t);
static void (*orig_abort)(void);
static int (*orig_getaddrinfo)(const char *, const char *, const struct addrinfo *, struct addrinfo **);

// --- الدوال البديلة ---
int my_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (is_untrusted_caller()) return -1;
    return orig_connect(sockfd, addr, addrlen);
}

void my_abort(void) {
    if (is_untrusted_caller()) return;
    orig_abort();
}

int my_getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res) {
    if (is_untrusted_caller()) return EAI_FAIL;
    return orig_getaddrinfo(node, service, hints, res);
}

// --- تفعيل نظام التخفي ---
void Apply_Stealth_Bypass() {
    // استخدام Fishhook لإعادة ربط رموز النظام (أقوى حماية)
    struct rebinding rebindings[] = {
        {"connect", (void *)my_connect, (void **)&orig_connect},
        {"abort", (void *)my_abort, (void **)&orig_abort},
        {"getaddrinfo", (void *)my_getaddrinfo, (void **)&orig_getaddrinfo}
    };
    rebind_symbols(rebindings, 3);

    // البحث الديناميكي عن دوال الحماية الإضافية
    const char* symbols[] = {"_AnoSDKGetReportData2", "ACE_Init"};
    for (int i = 0; i < 2; i++) {
        void *addr = dlsym(RTLD_DEFAULT, symbols[i]);
        if (addr) MSHookFunction(addr, (void *)NULL, NULL);
    }
}

// --- المحقن الرئيسي (مع تأخير 5 ثوانٍ) ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        Apply_Stealth_Bypass();
    });
}
