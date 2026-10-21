// stdin: SF Symbol names, one per line. Prints those this system can't draw, or with --present those it can.
#import <AppKit/AppKit.h>

int main(int argc, char **argv) {
    @autoreleasepool {
        BOOL present = argc > 1 && strcmp(argv[1], "--present") == 0;
        char line[1024];
        while (fgets(line, sizeof line, stdin)) {
            line[strcspn(line, "\n")] = 0;
            if (!line[0]) continue;
            BOOL drawn = [NSImage imageWithSystemSymbolName:@(line) accessibilityDescription:nil] != nil;
            if (drawn == present) printf("%s\n", line);
        }
    }
    return 0;
}
