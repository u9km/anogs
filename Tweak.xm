#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <sys/socket.h>
#import <netdb.h>
#import <dispatch/dispatch.h>

// ============================================================================
//  TITANIUM V18: SHADOW MASTER EVOLUTION (NON-JB / NO-CRASH)
//  الفلسفة: "المراقب الصامت" - اترك الحماية تعمل (للمحافظة على الاستقرار)
//  واقطع عنها لسانها (التقارير) وصلاحياتها (إغلاق اللعبة).
// ============================================================================

// --- 1. محرك التشفير (XOR Engine) ---
#define MASTER_KEY 0x4D

void shadow_decrypt(char *str, size_t len) {
    for (size_t i = 0; i < len; i++) {
        str[i] ^= MASTER_KEY;
    }
}

// --- 2. فحص المصدر (Target Detection) ---
bool is_protection_caller() {
    void *return_addr = __builtin_return_address(0);
    Dl_info info;
    if (dladdr(return_addr, &info) && info.dli_fname) {
        // تشفير "anogs" (Key 0x4D)
        char target[] = {0x2C, 0x23, 0x22, 0x2A, 0x3E, 0x00};
        shadow_decrypt(target, 5);
        if (strstr(info.dli_fname, target)) return true;
    }
    return false;
}

// --- 3. هوكات النظام (المراقب الصامت) ---

// أ. منع الاتصال (connect): الحماية تجمع بيانات لكنها لا تستطيع إرسالها
static int (*orig_connect)(int, const struct sockaddr *, socklen_t);
int new_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (is_protection_caller()) {
        // نقطع الخط بصمت ونوهمها أن الاتصال فشل تقنياً
        return -1; 
    }
    return orig_connect(sockfd, addr, addrlen);
}

// ب. منع الإرسال السريع (sendto): لإغلاق ثغرة UDP
static ssize_t (*orig_sendto)(int, const void *, size_t, int, const struct sockaddr *, socklen_t);
ssize_t new_sendto(int sockfd, const void *buf, size_t len, int flags, const struct sockaddr *dest_addr, socklen_t addrlen) {
    if (is_protection_caller()) return -1;
    return orig_sendto(sockfd, buf, len, flags, dest_addr, addrlen);
}

// ج. منع الانتحار (abort): حتى لو اكتشفتنا الحماية، لا نسمح لها بإغلاق اللعبة
static void (*orig_abort)(void);
void new_abort(void) {
    if (is_protection_caller()) {
        // نمنع إغلاق اللعبة (الكراش المتعمد)
        return; 
    }
    orig_abort();
}

// د. منع DNS (getaddrinfo): لمنع الحماية من معرفة عنوان السيرفر
static int (*orig_getaddrinfo)(const char *, const char *, const struct addrinfo *, struct addrinfo **);
int new_getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res) {
    if (is_protection_caller()) return EAI_FAIL;
    return orig_getaddrinfo(node, service, hints, res);
}

// --- 4. تفعيل وضع الشبح ---
void Deploy_Shadow_Master() {
    // نستخدم MSHook لدوال النظام (أكثر استقراراً في بيئة Framework)
    MSHookFunction((void *)connect, (void *)new_connect, (void **)&orig_connect);
    MSHookFunction((void *)sendto, (void *)new_sendto, (void **)&orig_sendto);
    MSHookFunction((void *)abort, (void *)new_abort, (void **)&orig_abort);
    MSHookFunction((void *)getaddrinfo, (void *)new_getaddrinfo, (void **)&orig_getaddrinfo);

    NSLog(@"[Titanium] Shadow Master V18 Deployed Safely.");
}

// --- 5. التشغيل المؤجل (لضمان تجاوز فحص البداية) ---
%ctor {
    // انتظار 10 ثوانٍ لكي تطمئن الحماية وتنهي فحص الذاكرة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        Deploy_Shadow_Master();
    });
}
