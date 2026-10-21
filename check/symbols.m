// stdin: SF Symbol names, one per line. Prints those this system can't draw.
#import <AppKit/AppKit.h>

int main(void) {
    @autoreleasepool {
        char line[1024];
        while (fgets(line, sizeof line, stdin)) {
            line[strcspn(line, "\n")] = 0;
            if (!line[0]) continue;
            if (![NSImage imageWithSystemSymbolName:@(line) accessibilityDescription:nil]) printf("%s\n", line);
        }
    }
    return 0;
}
