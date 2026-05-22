"""@dataclass is a decorator that inspects class annotations at
class-creation time and synthesizes __init__, __repr__, __eq__, etc.
The metaprogramming runs once, at import — not on every instance.

Inspect the generated __init__ signature with:
    import inspect
    print(inspect.signature(User.__init__))
(inspect.getsource doesn't work — @dataclass exec's __init__ from a
generated string, so there's no source file to read.)
"""

import json
from dataclasses import asdict, dataclass


@dataclass
class User:
    id: int
    name: str
    email: str
    active: bool


if __name__ == "__main__":
    u = User(id=42, name="alice", email="a@x.com", active=True)
    print(json.dumps(asdict(u)))
