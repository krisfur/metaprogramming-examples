# Metaprogramming examples

Companion code for a video walking through how different languages let you write code that writes code (metaprogramming).

The recurring thread is JSON serialization of the same struct:

```
User { id: 42, name: "alice", email: "a@x.com", active: true }
  ->  {"id":42,"name":"alice","email":"a@x.com","active":true}
```

Same problem, six mechanisms.

| #   | Folder                                  | Language    | Mechanism                               |
| --- | --------------------------------------- | ----------- | --------------------------------------- |
| 1   | [`1-C/`](1-C)                           | C           | X-macros (preprocessor)                 |
| 2   | [`2-Rust/`](2-Rust)                     | Rust        | `#[derive(Serialize)]` procedural macro |
| 3   | [`3-Python/`](3-Python)                 | Python      | `@dataclass` + custom decorator         |
| 4a  | [`4-Cpp/templates/`](4-Cpp/templates)   | C++17       | templates + `if constexpr`              |
| 4b  | [`4-Cpp/reflection/`](4-Cpp/reflection) | C++26       | static reflection (P2996)               |
| 5   | [`5-Zig/`](5-Zig)                       | Zig         | `comptime` + `@typeInfo` + `inline for` |
| 6   | [`6-Odin/`](6-Odin)                     | Odin        | parametric proc + `core:reflect`        |
| 7   | [`7-Lisp/`](7-Lisp)                     | Common Lisp | `defmacro` (code-as-data)               |

Excalidraw backdrop used:

[https://excalidraw.com/#json=A4RsdVrVl0EkHjZJ5b132,ZjJUeasVRn57jttQya7D1g](https://excalidraw.com/#json=A4RsdVrVl0EkHjZJ5b132,ZjJUeasVRn57jttQya7D1g)

## What each one shows

**1. `C` - X-macros** 

One `USER_FIELDS` list is the single source of truth. Redefining `X_U32` / `X_STR` / `X_BOOL` between expansions lets the same list emit the struct definition AND the `JSON` writer.

**2. `Rust` - derive macros** 

`serde_derive` is a procedural macro running in the compiler. It parses the struct, generates a `Serialize` impl, the rest is normal code. 

**3. `Python` - decorators** 

`@dataclass` inspects the class's annotations at import time and synthesises `__init__`, `__repr__`, `__eq__`. 

A second decorator, `@json_serializable`, walks the same annotations and builds a `to_json` method by `exec`-ing a generated source string.

**4a. `C++` - templates and `if constexpr`** 

The compiler stamps out specialised code per type. `if constexpr` branches on type traits at compile time, so a single template body can format strings, bools, and streamable types without any runtime branching - dead branches are discarded during instantiation.

**4b. `C++26` reflection (P2996)** 

`^^T` reifies a type into a `std::meta::info`, `[: m :]` splices it back, `template for` peels the loop at compile time.

**5. `Zig` - comptime** 

`@typeInfo(T)` returns a regular value; `switch`, `inline for`, and `@field` are normal Zig that happens to execute during compilation. Same generic serializer pattern, no derive, no runtime reflection. 

**6. `Odin` - runtime introspection** 

Odin's metaprogramming is parametric polymorphism plus `core:reflect` walking the `Type_Info` attached to `any` at runtime. Same problem solved without any codegen at all.

**7. `Common Lisp`** 

A macro is a function from code to code, and because the source is s-expressions the compile-time and runtime languages are the same language.

## Running each example

Most folders are a single source file; only the C and C++ examples have build scripts.

1. `C`

```bash
cd 1-C && ./run.sh
```

2. `Rust`

```bash
cd 2-Rust && cargo run --release
```

3. `Python`

```bash
uv run 3-Python/main.py
```

4a. `C++17`

```bash
cd 4-Cpp/templates && ./run.sh
```

4b. `C++26` + `P2996` support

`GCC 16.1` (April 2026) supports it via `-std=c++26 -freflection`, but isn't packaged everywhere yet. 

The `bloomberg/clang-p2996` fork is the easiest prebuilt path and what run.sh uses: [https://github.com/bloomberg/clang-p2996](https://github.com/bloomberg/clang-p2996)

```bash
cd 4-Cpp/reflection && CLANG_P2996=/opt/clang-p2996 ./run.sh
```

5. `Zig 0.16.0` 

```bash
cd 5-Zig && zig run main.zig
```

6. `Odin`

```bash
cd 6-Odin && odin run .
```

7. `Lisp`

```bash
sbcl --script 7-Lisp/main.lisp
```

## Seeing the codegen on screen

`Python`, `Odin`, and `Lisp` print their generated artefact (source string, `Type_Info` table, macroexpansion) as part of running the script.

`C` and `Rust` have external tools that show what the macro produced:

```sh
# C: full preprocessor output
cc -E 1-C/main.c | sed -n '/typedef struct/,/^}/p'

# Rust: expanded derive (needs `cargo install cargo-expand`)
cd 2-Rust && cargo expand
```

`C++` and `Zig` don't have a clean equivalent: template instantiation, `C++26` reflection, and `Zig`'s `comptime` all run inside the compiler with no source-level artefact to dump.
