// Templates: the compiler stamps out a specialized version of the
// function for every T you call it with. Same source code, different
// machine code per type. `if constexpr` lets us branch on type traits
// at compile time so the runtime path stays clean.

#include <iostream>
#include <sstream>
#include <string>
#include <type_traits>
#include <vector>

template <typename T>
std::string to_json_value(const T& v) {
    if constexpr (std::is_same_v<T, std::string>) {
        return "\"" + v + "\"";
    } else if constexpr (std::is_same_v<T, bool>) {
        return v ? "true" : "false";
    } else {
        std::ostringstream os;
        os << v;
        return os.str();
    }
}

template <typename T>
std::string to_json_array(const std::vector<T>& xs) {
    std::ostringstream os;
    os << '[';
    for (size_t i = 0; i < xs.size(); ++i) {
        if (i) os << ',';
        os << to_json_value(xs[i]);
    }
    os << ']';
    return os.str();
}

int main() {
    std::cout << to_json_array<int>({1, 2, 3}) << "\n";
    std::cout << to_json_array<std::string>({"alice", "bob"}) << "\n";
    // (std::vector<bool> is specialised and returns a proxy ref,
    // so skip it here; scalars work fine.)
    std::cout << to_json_value(true) << "\n";
    std::cout << to_json_value(std::string{"hello"}) << "\n";
}
