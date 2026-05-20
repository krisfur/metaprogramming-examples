// C++26 reflection (P2996). `^^T` reifies a type/value into a
// `std::meta::info`; `[: r :]` splices it back. This means we can
// iterate a struct's members at compile time *in the language itself*,
// not through external code generators or macros.
//
// Requires a compiler that implements P2996 — currently the
// bloomberg/clang-p2996 fork (https://github.com/bloomberg/clang-p2996).
// Mainstream clang/gcc do not have this yet as of 2026.

#include <experimental/meta>
#include <iostream>
#include <string>
#include <type_traits>

struct User {
    unsigned    id;
    std::string name;
    std::string email;
    bool        active;
};

template <typename T>
std::string to_json(const T& v) {
    std::string out = "{";
    bool first = true;
    template for (constexpr auto m : std::meta::nonstatic_data_members_of(^^T)) {
        if (!first) out += ",";
        first = false;
        out += "\"";
        out += std::meta::identifier_of(m);
        out += "\":";
        const auto& field = v.[:m:];
        using F = std::remove_cvref_t<decltype(field)>;
        if constexpr (std::is_same_v<F, std::string>) {
            out += "\"" + field + "\"";
        } else if constexpr (std::is_same_v<F, bool>) {
            out += field ? "true" : "false";
        } else {
            out += std::to_string(field);
        }
    }
    out += "}";
    return out;
}

int main() {
    User u{42, "alice", "a@x.com", true};
    std::cout << to_json(u) << "\n";
}
