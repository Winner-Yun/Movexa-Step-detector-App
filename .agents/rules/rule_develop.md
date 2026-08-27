---
trigger: always_on
---

## Code Comment Rules

Before asking me to add a comment to the code, first explain:

1. **Why the comment is needed**
2. **What the comment is supposed to explain**
3. **Which code/function/file the comment applies to**
4. **Whether the comment is necessary or optional**

Do not ask me to add comments just for the sake of commenting.

Only recommend comments when they provide useful context that cannot be easily understood from the code itself.

Prefer clear, self-explanatory code instead of excessive comments.

### Example

Before asking:

> "Should I add a comment here?"

First say:

> "This comment would explain why we use a 0.6 face-distance threshold here. The value is important to the face-verification logic and may not be obvious from the code. I recommend adding it."

Then ask me whether I want the comment added.

### Important

Never add comments automatically when I have not asked for them, unless the comment is necessary for generated code, configuration, or an important non-obvious behavior.

Do not add obvious comments such as:

```dart
// Create user
final user = User();
```

Prefer:

```dart
final user = User();
```

Comments should explain **why**, not simply repeat **what the code does**.
