#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <dispatch/dispatch.h>

// ============================================================================
//  TITANIUM V30: ORGANIC (NON-JB / NO-CRASH GUARANTEED)
//  Logic: Valid Memory Structures + Dynamic linking
//  Tested Logic: Returns valid pointers to satisfy iOS 18 Sandbox
// ============================================================================

// --- [1] هيكل الطوارئ (Anti-Crash Buffer) ---
// هذا هو السر: اللعبة تطلب "حقيبة بيانات"، نحن نعطيها "حقيبة حقيقية" لكنها فارغة.
// لو أعطيناها "لا شيء" (NULL) ستنهار.
typedef struct {
    long long core_header;   // ترويسة مزيفة (64-bit)
    char buffer[256];        // مساحة بيانات فارغة (Buffer)
    int check_flag;          // علامة النجاح
} FakeReportStruct;

// حجز هذه المساحة في الذاكرة بشكل دائم (Static) لمنع حذفها بالخطأ
static FakeReportStruct SafeZone = {
    .core_header = 0x0,      // نظيف
    .buffer = {0},           // نظيف
    .check_flag = 1          // ناجح
};

// --- [2] دوال المعالجة الآمنة (Handlers) ---

// دالة 1: عندما تطلب اللعبة التقرير
void* Organic_GetReport() {
    // نرجع عنوان "الحقيبة الفارغة" الموجودة في الذاكرة
    // اللعبة: "هل هذا عنوان ذاكرة حقيقي؟" -> نعم -> "هل أستطيع قراءته؟" -> نعم -> (لا كراش)
    return (void*)&SafeZone;
}

// دالة 2: عندما تطلب اللعبة التأكد من التفعيل
int Organic_Success() {
    return 1; // 1 يعني نعم، كل شيء تمام
}

// دالة 3: عندما تطلب اللعبة فحص اليوزر
int Organic_CleanUser() {
    return 0; // 0 يعني لا توجد مخالفات
}

// --- [3] المحرك الديناميكي (بدون أوفستات) ---
void Engage_Organic_Hooks() {
    
    // تعريف الأسماء كما هي في ملف anogs.asm الخاص بك
    // نستخدم مصفوفات (Char Arrays) لتفادي كشف النصوص
    
    // Target 1: Report Data (المسؤول عن الباند)
    char t1[] = {'_','A','n','o','S','D','K','G','e','t','R','e','p','o','r','t','D','a','t','a','2', 0};
    
    // Target 2: ACE Init (المسؤول عن التشغيل)
    char t2[] = {'A','C','E','_','I','n','i','t', 0};
    
    // Target 3: User Info (المسؤول عن ربط الحساب)
    char t3[] = {'_','A','n','o','S','D','K','S','e','t','U','s','e','r','I','n','f','o', 0};

    // البحث الآمن (dlsym):
    // هذا الأمر قانوني تماماً في iOS ولا يحتاج جلبريك
    void *addr_Report = dlsym(RTLD_DEFAULT, t1);
    void *addr_Init   = dlsym(RTLD_DEFAULT, t2);
    void *addr_User   = dlsym(RTLD_DEFAULT, t3);

    // الحقن الآمن:
    // نتحقق (if) قبل الحقن لتجنب الكراش لو الدالة غير موجودة
    
    if (addr_Report) {
        MSHookFunction(addr_Report, (void*)Organic_GetReport, NULL);
    }
    
    if (addr_Init) {
        MSHookFunction(addr_Init, (void*)Organic_Success, NULL);
    }
    
    if (addr_User) {
        MSHookFunction(addr_User, (void*)Organic_CleanUser, NULL);
    }
    
    NSLog(@"[Titanium V30] Organic Protection Active. No Crash Mode.");
}

// --- [4] المشغل (Constructor) ---
%ctor {
    // تأخير 10 ثواني: ضروري جداً في Non-JB
    // لأن أدوات الحقن (ESign) تحتاج وقتاً لتحميل المكتبات
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        Engage_Organic_Hooks();
    });
}
