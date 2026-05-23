"""Two decorators, both metaprogramming:

- @dataclass synthesises __init__/__repr__/__eq__ from annotations.
- @json_serializable below generates a to_json method the same way:
  walk __annotations__, build a source string, exec it, attach it.

Same idea as Rust's #[derive(Serialize)] or the C X-macros — code
that writes code — just at import time in a dynamic language.

Inspect the generated methods with:
    import inspect
    print(inspect.signature(User.__init__))
    print(User.to_json.__source__)
"""

import json
from dataclasses import dataclass


def json_serializable(cls):
    """Generate a to_json method from cls.__annotations__."""
    parts = []
    for name, typ in cls.__annotations__.items():
        if typ is str:
            parts.append(f'"\\"{name}\\":\\"" + self.{name} + "\\""')
        elif typ is bool:
            parts.append(f'"\\"{name}\\":" + ("true" if self.{name} else "false")')
        else:
            parts.append(f'"\\"{name}\\":" + str(self.{name})')
    body = ' + "," + '.join(parts)
    src = f"def to_json(self):\n    return '{{' + {body} + '}}'\n"
    ns: dict = {}
    exec(src, ns)
    cls.to_json = ns["to_json"]
    cls.to_json.__source__ = src
    return cls


@json_serializable
@dataclass
class User:
    id: int
    name: str
    email: str
    active: bool


if __name__ == "__main__":
    u = User(id=42, name="alice", email="a@x.com", active=True)
    print("generated to_json:")
    print(User.to_json.__source__)  # ty: ignore[unresolved-attribute]
    print("output:")
    print(u.to_json())  # ty: ignore[unresolved-attribute]
    print("stdlib equivalent for comparison:")
    print(
        json.dumps({"id": u.id, "name": u.name, "email": u.email, "active": u.active})
    )
