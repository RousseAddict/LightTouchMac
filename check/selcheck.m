// argv: system libraries to load. stdin: selector names. Prints those no loaded class implements.
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <objc/runtime.h>

int main(int argc, char **argv) {
    @autoreleasepool {
        for (int i = 1; i < argc; i++) {
            if (strncmp(argv[i], "/System/", 8) == 0 || strncmp(argv[i], "/usr/lib/", 9) == 0) dlopen(argv[i], RTLD_LAZY);
        }
        NSMutableSet<NSString *> *implemented = [NSMutableSet set];
        unsigned int classCount = 0;
        Class *classes = objc_copyClassList(&classCount);
        for (unsigned int c = 0; c < classCount; c++) {
            Class targets[2] = {classes[c], object_getClass((id)classes[c])};
            for (int t = 0; t < 2; t++) {
                unsigned int n = 0;
                Method *methods = class_copyMethodList(targets[t], &n);
                for (unsigned int m = 0; m < n; m++) [implemented addObject:NSStringFromSelector(method_getName(methods[m]))];
                free(methods);
            }
        }
        free(classes);
        char line[4096];
        while (fgets(line, sizeof line, stdin)) {
            line[strcspn(line, "\n")] = 0;
            if (![implemented containsObject:@(line)]) printf("%s\n", line);
        }
        fprintf(stderr, "%u classes, %lu selectors implemented\n", classCount, (unsigned long)implemented.count);
    }
    return 0;
}
