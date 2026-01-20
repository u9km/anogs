#import <dlfcn.h>
#import <stdlib.h>
#import <string.h>
#import <sys/types.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

// ============================================================================
//  TITANIUM V-INFINITY: THE END GAME
//  ALL-IN-ONE PROTECTION SUITE (NON-JB / NO CRASH)
// ============================================================================

// ----------------------------------------------------------------------------
// PART 1: FISHHOOK ENGINE (محرك الاستبدال الآمن - لا تعدل هنا)
// ----------------------------------------------------------------------------
#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct section_64 section_t;
typedef struct nlist_64 nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct section section_t;
typedef struct nlist nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

struct rebinding { const char *name; void *replacement; void **replaced; };
struct rebindings_entry { struct rebinding *rebindings; size_t rebindings_nel; struct rebindings_entry *next; };
static struct rebindings_entry *_rebindings_head;

static int prepend_rebindings(struct rebindings_entry **rebindings_head, struct rebinding rebindings[], size_t rebindings_nel) {
    struct rebindings_entry *new_entry = (struct rebindings_entry *)malloc(sizeof(struct rebindings_entry));
    if (!new_entry) return -1;
    new_entry->rebindings = (struct rebinding *)malloc(sizeof(struct rebinding) * rebindings_nel);
    if (!new_entry->rebindings) { free(new_entry); return -1; }
    memcpy(new_entry->rebindings, rebindings, sizeof(struct rebinding) * rebindings_nel);
    new_entry->rebindings_nel = rebindings_nel;
    new_entry->next = *rebindings_head;
    *rebindings_head = new_entry;
    return 0;
}

static void perform_rebinding_with_section(struct rebindings_entry *rebindings, section_t *section, intptr_t slide, nlist_t *symtab, char *strtab, uint32_t *indirect_symtab) {
    uint32_t *indirect_symbol_indices = (uint32_t *)(slide + section->offset);
    void **indirect_symbol_bindings = (void **)(slide + section->addr);
    for (uint32_t i = 0; i < section->size / sizeof(void *); i++) {
        uint32_t symtab_index = indirect_symbol_indices[i];
        if (symtab_index == INDIRECT_SYMBOL_ABS || symtab_index == INDIRECT_SYMBOL_LOCAL || symtab_index == (INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS)) continue;
        uint32_t strtab_offset = symtab[symtab_index].n_un.n_strx;
        char *symbol_name = strtab + strtab_offset;
        if (strnlen(symbol_name, 2) < 2) continue;
        struct rebindings_entry *cur = rebindings;
        while (cur) {
            for (uint32_t j = 0; j < cur->rebindings_nel; j++) {
                if (strcmp(&symbol_name[1], cur->rebindings[j].name) == 0) {
                    if (cur->rebindings[j].replaced != NULL && indirect_symbol_bindings[i] != cur->rebindings[j].replacement) {
                        *(cur->rebindings[j].replaced) = indirect_symbol_bindings[i];
                    }
                    indirect_symbol_bindings[i] = cur->rebindings[j].replacement;
                    goto symbol_loop;
                }
            }
            cur = cur->next;
        }
    symbol_loop:;
    }
}

static void rebind_symbols_image(const struct mach_header *header, intptr_t slide) {
    Dl_info info;
    if (dladdr(header, &info) == 0) return;
    segment_command_t *cur_seg_cmd;
    segment_command_t *linkedit_segment = NULL;
    struct symtab_command* symtab_cmd = NULL;
    struct dysymtab_command* dysymtab_cmd = NULL;
    uintptr_t cur = (uintptr_t)header + sizeof(mach_header_t);
    for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t *)cur;
        if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            if (strcmp(cur_seg_cmd->segname, "__LINKEDIT") == 0) linkedit_segment = cur_seg_cmd;
        } else if (cur_seg_cmd->cmd == LC_SYMTAB) symtab_cmd = (struct symtab_command*)cur_seg_cmd;
        else if (cur_seg_cmd->cmd == LC_DYSYMTAB) dysymtab_cmd = (struct dysymtab_command*)cur_seg_cmd;
    }
    if (!symtab_cmd || !dysymtab_cmd || !linkedit_segment || !dysymtab_cmd->nindirectsyms) return;
    uintptr_t linkedit_base = (uintptr_t)slide + linkedit_segment->vmaddr - linkedit_segment->fileoff;
    nlist_t *symtab = (nlist_t *)(linkedit_base + symtab_cmd->symoff);
    char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);
    uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);
    cur = (uintptr_t)header + sizeof(mach_header_t);
    for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t *)cur;
        if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            if (strcmp(cur_seg_cmd->segname, "__DATA") != 0 && strcmp(cur_seg_cmd->segname, "__DATA_CONST") != 0) continue;
            for (uint j = 0; j < cur_seg_cmd->nsects; j++) {
                section_t *sect = (section_t *)(cur + sizeof(segment_command_t)) + j;
                if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS || (sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
                    perform_rebinding_with_section(_rebindings_head, sect, slide, symtab, strtab, indirect_symtab);
                }
            }
        }
    }
}

int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel) {
    int retval = prepend_rebindings(&_rebindings_head, rebindings, rebindings_nel);
    if (retval < 0) return retval;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        rebind_symbols_image((const struct mach_header *)_dyld_get_image_header(i), _dyld_get_image_vmaddr_slide(i));
    }
    return retval;
}

// ----------------------------------------------------------------------------
// PART 2: C-LEVEL PROTECTION (Anogs & Files & Injection)
// ----------------------------------------------------------------------------

// 1. حماية التقارير (Anogs Report Bypass) - يمنع الباند 10 دقايق/سبوع
void* Fake_Report() {
    void* ptr = malloc(512); // ذاكرة نظيفة لمنع الكراش
    if (ptr) memset(ptr, 0, 512);
    return ptr;
}

// 2. حماية التشغيل (Anogs Init Bypass)
int Fake_Success() { return 1; }

// 3. حماية الهوية (User Info Bypass)
int Fake_CleanUser() { return 0; }

// 4. حارس الدايلب (Anti-Injection Guardian)
// يمنع تحميل ملفات الغش الأخرى التي قد تسبب لك باند
void* (*orig_dlopen)(const char* path, int mode);
void* my_dlopen(const char* path, int mode) {
    if (path) {
        if (strstr(path, "Cheat") || strstr(path, "Hack") || 
            strstr(path, "Esp") || strstr(path, "Menu") || 
            strstr(path, "Mod") || strstr(path, "Hook")) {
            
            // استثناء: لا تحظر ملفاتنا
            if (!strstr(path, "Titanium") && !strstr(path, "Substrate")) {
                return NULL; // منع التحميل
            }
        }
    }
    return orig_dlopen(path, mode);
}

// 5. حماية الملفات (Anti-Crack & Anti-Ghayabi)
// يمنع اللعبة من رؤية ملفات الجلبريك + يمنع قراءة ملفات اللوج (ano_tmp)
int (*orig_open)(const char *, int, ...);
int my_open(const char *path, int oflag, ...) {
    if (path) {
        // قائمة الحظر الصارمة
        if (strstr(path, "ano_tmp") || strstr(path, "tss_tmp") || 
            strstr(path, "Cydia") || strstr(path, "MobileSubstrate") || 
            strstr(path, "apt") || strstr(path, "Replay") ||
            strstr(path, "embedded.mobileprovision")) { // يخفي الكراك
            return -1; 
        }
    }
    return orig_open(path, oflag);
}

// ----------------------------------------------------------------------------
// PART 3: OBJC SWIZZLING (ShadowTracker & Network & ID)
// ----------------------------------------------------------------------------

// A. تزوير الهوية (ضد باند 10 سنوات)
@interface FakeDevice : NSObject
@end
@implementation FakeDevice
- (NSUUID *)fake_identifierForVendor {
    return [NSUUID UUID]; // معرف جهاز جديد كل مرة
}
@end

// B. جدار الحماية الشبكي (ضد الشادو تراكر + حماية السكنات)
// هذا أهم جزء لحماية السكنات: يمنع اللعبة من إرسال "تقرير اختلاف الملفات"
@interface FakeSession : NSObject
@end
@implementation FakeSession
- (NSURLSessionDataTask *)fake_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    
    NSString *url = [[request URL] absoluteString];
    
    // الفلتر النووي
    if ([url containsString:@"report"] || 
        [url containsString:@"dataflow"] || 
        [url containsString:@"analytics"] || 
        [url containsString:@"crashsight"] || // يبلغ عن تعديل الملفات (السكنات)
        [url containsString:@"file-upload"] || // يرفع اللوجات
        [url containsString:@"gcloud"] || 
        [url containsString:@"cdn"] && [url containsString:@"check"] || // تحقق السكنات
        [url containsString:@"cs.mbgame"]) {
        
        // قطع الاتصال بصمت
        if (completionHandler) {
             completionHandler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]);
        }
        return nil;
    }
    
    // تمرير الاتصال الطبيعي (اللعب)
    return [self fake_dataTaskWithRequest:request completionHandler:completionHandler];
}
@end

// ----------------------------------------------------------------------------
// PART 4: EXECUTION (التشغيل)
// ----------------------------------------------------------------------------

static void Swizzle(Class cls, SEL original, SEL replacement) {
    Method origMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, replacement);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, original, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static __attribute__((constructor)) void Init_Infinity() {
    
    // 1. عملية التطهير (Wiper) - تحرق الأدلة القديمة
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *targets = @[
        [doc stringByAppendingPathComponent:@"ano_tmp"], 
        [doc stringByAppendingPathComponent:@"tss_tmp"],
        [doc stringByAppendingPathComponent:@"ShadowTrackerExtra/Saved/Logs"],
        [doc stringByAppendingPathComponent:@"ShadowTrackerExtra/Saved/Paks/Replay"]
    ];
    for (NSString *path in targets) {
        if ([fm fileExistsAtPath:path]) [fm removeItemAtPath:path error:nil];
    }

    // 2. تشغيل FishHook (C-Level Protection)
    struct rebinding rebindings[] = {
        {"ACE_Init", (void *)Fake_Success, NULL},
        {"AntiCheatExpert_Init", (void *)Fake_Success, NULL},
        {"_AnoSDKGetReportData2", (void *)Fake_Report, NULL},
        {"_TssSDKGetReportData", (void *)Fake_Report, NULL},
        {"_AnoSDKSetUserInfo", (void *)Fake_CleanUser, NULL},
        {"open", (void *)my_open, (void **)&orig_open},
        {"dlopen", (void *)my_dlopen, (void **)&orig_dlopen}
    };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(struct rebinding));
    
    // 3. تشغيل Swizzling (ObjC Protection)
    Swizzle([UIDevice class], @selector(identifierForVendor), @selector(fake_identifierForVendor));
    Swizzle([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), @selector(fake_dataTaskWithRequest:completionHandler:));
    
    NSLog(@"[Titanium V-Infinity] Active. Full Spectrum Protection.");
}
