// Templates + constexpr-if: the C++17 metaprogramming toolkit.
//
// Templates make the compiler stamp out a specialized version of the
// function for every T you call it with — same source code, different
// machine code per type. `if constexpr` then lets a single template
// body branch on type traits at compile time; the dead branches are
// thrown away during instantiation, so the runtime path stays clean.
//
// The catch: C++17 has no way to walk a struct's fields. `to_json` for
// `User` has to list them by hand. That's the gap C++26 reflection
// fills (see ../reflection/).

#include <iostream>
#include <sstream>
#include <string>
#include <type_traits>

struct User {
    unsigned    id;
    std::string name;
    std::string email;
    bool        active;
};

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

std::string to_json(const User& u) {
    std::string out = "{";
    out += "\"id\":"     + to_json_value(u.id)     + ",";
    out += "\"name\":"   + to_json_value(u.name)   + ",";
    out += "\"email\":"  + to_json_value(u.email)  + ",";
    out += "\"active\":" + to_json_value(u.active);
    out += "}";
    return out;
}

int main() {
    User u{42, "alice", "a@x.com", true};
    std::cout << to_json(u) << "\n";
}
