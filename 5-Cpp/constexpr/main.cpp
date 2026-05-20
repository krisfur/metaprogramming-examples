// constexpr: evaluate at compile time when inputs are known.
// Realistic use: hash string literals at compile time so you can
// `switch` on strings, which the language otherwise forbids.
//
// Every `"start"_h` below is computed during compilation — the binary
// just contains the resulting u64 constants.

#include <cstdint>
#include <iostream>
#include <string_view>

constexpr uint64_t fnv1a(std::string_view s) {
    uint64_t h = 14695981039346656037ull;
    for (char c : s) {
        h ^= static_cast<uint8_t>(c);
        h *= 1099511628211ull;
    }
    return h;
}

constexpr uint64_t operator""_h(const char* s, size_t n) {
    return fnv1a({s, n});
}

void dispatch(std::string_view cmd) {
    switch (fnv1a(cmd)) {
        case "start"_h: std::cout << "starting\n"; break;
        case "stop"_h:  std::cout << "stopping\n"; break;
        case "ping"_h:  std::cout << "pong\n";     break;
        default:        std::cout << "unknown: " << cmd << "\n";
    }
}

int main() {
    static_assert(fnv1a("start") != fnv1a("stop"));
    dispatch("start");
    dispatch("ping");
    dispatch("nope");
}
