# Property-Based Testing Extension

When enabled, these rules enforce property-based testing alongside standard example-based tests. Property-based tests verify invariants over randomized inputs, catching edge cases that hand-written examples miss.

---

## Rule TEST-01: Identify Properties

### Rule
For every module with business logic, data transformation, or algorithm implementation, at least ONE property-based test MUST be defined that verifies a fundamental invariant of the system.

### Verification
- [ ] Each business logic module has at least one property-based test
- [ ] Properties describe invariants (not just examples with random data)
- [ ] Properties cover: round-trip/inverse operations, idempotency, commutativity, domain invariants, or oracle comparisons

---

## Rule TEST-02: Input Generation

### Rule
Property-based tests MUST use appropriate input generation strategies. Generators must produce values within the valid domain (constrained generation) and edge cases must be explicitly included via shrinking or targeted strategies.

### Verification
- [ ] Tests use the language's standard PBT library (Hypothesis for Python, fast-check for JS/TS, QuickCheck for Haskell, jqwik for Java)
- [ ] Input generators are constrained to valid domain ranges
- [ ] Edge cases are covered (empty collections, boundary values, special characters)
- [ ] Custom strategies are defined for domain-specific types

---

## Rule TEST-03: Shrinking and Reproducibility

### Rule
Failing test cases MUST be reproducible. The testing framework must support automatic shrinking to find minimal failing examples. Seeds or database storage must be used to replay failures.

### Verification
- [ ] Failing examples are minimized (shrinking is enabled/not disabled)
- [ ] Test database or seed is stored so failures can be reproduced
- [ ] CI configuration preserves test artifacts for debugging
- [ ] Flaky tests due to randomness are investigated (not skipped)

---

## Rule TEST-04: Coverage Targets

### Rule
Property-based tests MUST cover at minimum:
- Data serialization/deserialization (round-trip property)
- State machine transitions (valid states remain valid)
- Business calculations (known mathematical properties)
- API contract validation (responses match schema for all valid inputs)

### Verification
- [ ] Serialization code has round-trip tests (encode→decode = identity)
- [ ] State machines have transition validity properties
- [ ] Calculations verify algebraic properties (associativity, commutativity where applicable)
- [ ] API handlers are tested with schema-conformance properties

---

## Rule TEST-05: Integration with CI

### Rule
Property-based tests MUST run in CI with a sufficient number of examples (minimum 100 per property in CI, configurable). Local development may use fewer examples for speed, but CI must be thorough.

### Verification
- [ ] CI runs PBT with at least 100 examples per property (`--hypothesis-seed` or equivalent config)
- [ ] Local dev profile allows reduced examples for speed
- [ ] PBT failures block the build (not treated as warnings)
- [ ] Test timeout is configured to prevent infinite loops from bad generators

---

## Language-Specific Libraries

| Language | Library | Config |
|----------|---------|--------|
| Python | `hypothesis` | `settings(max_examples=100)` in CI |
| TypeScript/JavaScript | `fast-check` | `fc.assert(property, { numRuns: 100 })` |
| Java | `jqwik` | `@Property(tries = 100)` |
| Scala | `ScalaCheck` | `minSuccessful(100)` |
| Rust | `proptest` | `PROPTEST_CASES=100` env var |

---

## Enforcement

These rules are checked at the following AIDLC stages:

| Stage | Rules Checked |
|-------|--------------|
| Functional Design | TEST-01 (identify properties for domain entities) |
| Code Generation | TEST-01, TEST-02, TEST-03, TEST-04 |
| Build and Test | TEST-03, TEST-05 |

At each stage, the agent MUST verify applicable rules before allowing the stage to complete. If any rule fails verification, the finding must be resolved before proceeding.
