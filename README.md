# Metaprogramming examples

Companion code for a video walking through how different languages let
you write code that writes code (metaprogramming).

The recurring thread is JSON
serialization of the same struct:

```
User { id: 42, name: "alice", email: "a@x.com", active: true }
  ->  {"id":42,"name":"alice","email":"a@x.com","active":true}
```

Same problem, seven mechanisms.

| #   | Folder                                  | Language    | Mechanism                               |
| --- | --------------------------------------- | ----------- | --------------------------------------- |
| 1   | [`1-C/`](1-C)                           | C           | X-macros (preprocessor)                 |
| 2   | [`2-Rust/`](2-Rust)                     | Rust        | `#[derive(Serialize)]` procedural macro |
| 3   | [`3-Python/`](3-Python)                 | Python      | `@dataclass` decorator                  |
| 4   | [`4-Odin/`](4-Odin)                     | Odin        | parametric proc + `core:reflect`        |
| 5a  | [`5-Cpp/templates/`](5-Cpp/templates)   | C++17       | templates + `if constexpr`              |
| 5b  | [`5-Cpp/constexpr/`](5-Cpp/constexpr)   | C++20       | compile-time evaluation (FNV1a switch)  |
| 5c  | [`5-Cpp/reflection/`](5-Cpp/reflection) | C++26       | static reflection (P2996)               |
| 6   | [`6-Zig/`](6-Zig)                       | Zig         | `comptime` + `@typeInfo` + `inline for` |
| 7   | [`7-Lisp/`](7-Lisp)                     | Common Lisp | `defmacro` (code-as-data)               |

## What each one shows

**1-C — X-macros.** One `USER_FIELDS` list is the single source of
truth. Redefining `X_U32` / `X_STR` / `X_BOOL` between expansions lets
the same list emit the struct definition _and_ the JSON writer. Add a
field by adding one line.

**2 Rust — derive macro.** `serde_derive` is a procedural macro
running in the compiler. It parses the struct, generates a `Serialize`
impl, the rest is normal code. Direct upgrade from C macros: same
codegen idea, but operating on ASTs instead of tokens. Inspect with
`cargo expand`.

**3 Python — decorator.** `@dataclass` inspects the class's
annotations _at import time_ and synthesises `__init__`, `__repr__`,
`__eq__`. A second decorator, `@json_serializable`, walks the same
annotations and builds a `to_json` method by `exec`-ing a generated
source string. Same idea as Rust's derive, moved from compile time
to import time in a dynamic language. The script prints the generated
source before running it.

**4 Odin — runtime introspection.** Odin has no user macros and no
proc macros. Its metaprogramming is parametric polymorphism plus
`core:reflect` walking the Type_Info attached to `any` at runtime.
The "or you skip codegen entirely" counterpoint to Rust/Python.

**5a C++ templates.** The compiler stamps out specialised code per
type. `if constexpr` branches on traits at compile time so runtime
stays branch-free. (The `std::vector<bool>` proxy quirk is skipped in
the demo — left as a comment.)

**5b C++ constexpr.** Realistic use: `fnv1a` on a string literal at
compile time so you can `switch` on strings, which the language
otherwise forbids.

**5c C++26 reflection (P2996).** `^^T` reifies a type into a
`std::meta::info`, `[: m :]` splices it back, `template for` peels the
loop at compile time. No external codegen, no macros, just the language reflecting on itself.

**6 Zig comptime.** `@typeInfo(T)` returns a regular value; `switch`,
`inline for`, and `@field` are normal Zig that happens to execute
during compilation. Same generic serializer pattern, no derive, no
runtime reflection.

**7 Common Lisp.** The original. A macro is a function from code to
code, and because the source _is_ s-expressions the compile-time and
runtime languages are the same language. The script prints the
macroexpansion of `(define-json-serializer ...)` before running it.

## Running each example

Most folders are a single source file; only the C and C++ examples
have build scripts.

```sh
# 1-C
cd 1-C && ./run.sh

# 2 Rust
cd 2-Rust && cargo run --release

# 3 Python
python3 3-Python/main.py

# 4 Odin
cd 4-Odin && odin run .

# 5a / 5b C++ (mainstream clang/gcc)
cd 5-Cpp/templates && ./run.sh
cd 5-Cpp/constexpr && ./run.sh

# 5c C++26 reflection — needs the bloomberg/clang-p2996 fork
#   https://github.com/bloomberg/clang-p2996
cd 5-Cpp/reflection && CLANG_P2996=/opt/clang-p2996 ./run.sh

# 6 Zig (tested with 0.16.0; IO/ArrayList APIs churn between releases)
cd 6-Zig && zig run main.zig

# 7 Lisp
brew install sbcl   # if needed
sbcl --script 7-Lisp/main.lisp
```

## Seeing the codegen on screen

Some of these get more pedagogical when you can see what the macro
actually produced:

```sh
# C: full preprocessor output
cc -E 1-C/main.c | sed -n '/typedef struct/,/^}/p'

# Rust: expanded derive (needs `cargo install cargo-expand`)
cd 2-Rust && cargo expand

# Python: the dataclass __init__ signature + the generated to_json source
# (inspect.getsource doesn't work on @dataclass-generated __init__ — it's
# exec'd from a string with no source file. The @json_serializable decorator
# stashes its source on the method itself, so we can print that directly.)
cd 3-Python && python3 -c "import inspect; from main import User; print(inspect.signature(User.__init__)); print(User.to_json.__source__)"

# Lisp: macroexpansion is printed by main.lisp itself
```
