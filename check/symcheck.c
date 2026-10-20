// Reads "binary\tlibpath\tsymbol\tweak" lines on stdin; for each, reports whether this OS's
// library exists and exports the symbol. Only system libraries are ever dlopen'ed.
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLIBS 512
static char *libNames[MAXLIBS];
static void *libHandles[MAXLIBS];
static int libCount;

static void *handleFor(const char *path, int *missing) {
    for (int i = 0; i < libCount; i++) {
        if (strcmp(libNames[i], path) == 0) {
            *missing = libHandles[i] == NULL;
            return libHandles[i];
        }
    }
    void *h = dlopen(path, RTLD_LAZY | RTLD_LOCAL);
    if (libCount < MAXLIBS) {
        libNames[libCount] = strdup(path);
        libHandles[libCount++] = h;
    }
    *missing = h == NULL;
    return h;
}

int main(void) {
    char line[8192];
    while (fgets(line, sizeof line, stdin)) {
        line[strcspn(line, "\n")] = 0;
        char *bin = strtok(line, "\t"), *lib = strtok(NULL, "\t"), *sym = strtok(NULL, "\t"), *weak = strtok(NULL, "\t");
        if (!bin || !lib || !sym || !weak) continue;
        if (!getenv("SYMCHECK_CLT") && strncmp(lib, "/System/", 8) != 0 && strncmp(lib, "/usr/lib/", 9) != 0) continue;
        if (getenv("SYMCHECK_CLT") && strncmp(lib, "/Library/Developer/CommandLineTools/", 36) != 0) continue;
        int missing;
        void *h = handleFor(lib, &missing);
        const char *status;
        if (missing) status = "LIBMISSING";
        else status = dlsym(h, sym[0] == '_' ? sym + 1 : sym) ? "ok" : "SYMMISSING";
        printf("%s\t%s\t%s\t%s\t%s\n", status, bin, lib, sym, weak);
    }
    return 0;
}
