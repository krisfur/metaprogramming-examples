"""@dataclass is a decorator that inspects class annotations at
class-creation time and synthesizes __init__, __repr__, __eq__, etc.
The metaprogramming runs once, at import — not on every instance.

Inspect the generated __init__ with:
    import inspect, dataclasses
    print(inspect.getsource(User.__init__))
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
