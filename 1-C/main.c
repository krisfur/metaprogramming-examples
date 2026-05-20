// X-macros: one schema list expands into a struct definition,
// a field-printer, and could just as easily drive an enum->string
// table, ORM bindings, RPC stubs, etc. Common idiom in real C code
// (kernels, game engines) to keep a single source of truth.

#include <stdio.h>
#include <stdbool.h>

#define USER_FIELDS        \
    X_U32 (id)             \
    X_STR (name)           \
    X_STR (email)          \
    X_BOOL(active)

typedef struct {
#define X_U32(n)  unsigned    n;
#define X_STR(n)  const char *n;
#define X_BOOL(n) bool        n;
    USER_FIELDS
#undef X_U32
#undef X_STR
#undef X_BOOL
} User;

static void user_to_json(const User *u, FILE *out) {
    fputc('{', out);
    int first = 1;
#define COMMA do { if (!first) fputc(',', out); first = 0; } while (0)
#define X_U32(n)  COMMA; fprintf(out, "\"" #n "\":%u",         u->n);
#define X_STR(n)  COMMA; fprintf(out, "\"" #n "\":\"%s\"",     u->n);
#define X_BOOL(n) COMMA; fprintf(out, "\"" #n "\":%s", u->n ? "true" : "false");
    USER_FIELDS
#undef X_U32
#undef X_STR
#undef X_BOOL
#undef COMMA
    fputc('}', out);
}

int main(void) {
    User u = { .id = 42, .name = "alice", .email = "a@x.com", .active = true };
    user_to_json(&u, stdout);
    fputc('\n', stdout);
    return 0;
}
