# Sandi Metz Recommendations

Additional guidance from Sandi Metz beyond the 4 Rules.

## The 4 Rules (Summary)

1. **100 lines per class** - Extract when exceeded
2. **5 lines per method** - Extract helper methods
3. **4 parameters max** - Use parameter objects
4. **1 object per controller** - Use facades

**Rule 0**: Break rules only with explicit justification.

## Code Smells to Watch For

### Squint Test
If you squint at your code and see inconsistent shapes (varying indentation depths), the code likely has:
- Nested conditionals that should be guard clauses
- Mixed abstraction levels
- Too many responsibilities

### Shotgun Surgery
If changing one feature requires editing many files, your abstractions are wrong. Related behavior should be co-located.

### Feature Envy
If a method references another object's data more than its own, the method belongs on that other object.

## Refactoring Guidance

### When to Extract
- **Duplicate code** - Wait for 3 occurrences before extracting (Rule of Three)
- **Long methods** - Extract when intent is unclear, not just when long
- **Comments explaining code** - Extract to method with descriptive name instead

### How to Name
- Method names should describe **what**, not **how**
- If you can't name it simply, it does too much
- Prefer verbs for methods, nouns for classes

## Testing Principles

### Test Behavior, Not Implementation
- Test public interface only
- Don't test private methods directly
- Mock at boundaries, not internals

### Minimal Test Setup
- If test setup is complex, the code design is wrong
- Tests should be obvious and simple
- Each test should test one thing

## Object-Oriented Design

### Composition Over Inheritance
- Prefer injecting collaborators over extending base classes
- Inheritance creates tight coupling
- Use modules for shared behavior, not inheritance

### Depend on Abstractions
- High-level modules shouldn't depend on low-level modules
- Inject dependencies, don't hardcode them
- Program to interfaces, not implementations

### Single Responsibility
- A class should have only one reason to change
- If description uses "and" or "or", split it
- Smaller classes are easier to understand and test
