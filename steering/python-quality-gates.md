---
inclusion: fileMatch
fileMatchPattern: "**/*.py"
---

# Python Quality Gates

When the project involves Python code, enforce these quality gates during Code Generation and Build & Test stages.

---

## 1. Unit Testing (pytest)

### Standards

- Use **pytest** as the test framework (not unittest directly)
- Test files go in `tests/` mirroring the source layout: `src/foo/bar.py` → `tests/foo/test_bar.py`
- Test functions use the `test_` prefix; test classes use `Test` prefix (no `__init__`)
- Use **fixtures** (`conftest.py`) for shared setup — avoid test inheritance hierarchies
- Use `pytest.mark.parametrize` for data-driven tests
- Mock external dependencies with `unittest.mock.patch` or `pytest-mock`
- Minimum coverage threshold: **80%** (enforce with `--cov-fail-under=80`)

### Required Configuration

```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--strict-markers --tb=short -q"
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks integration tests",
]

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
fail_under = 80
show_missing = true
skip_empty = true
```

### Commands

```bash
# Run unit tests with coverage
pytest tests/ --cov --cov-report=term-missing --cov-fail-under=80

# Run only fast unit tests (exclude integration/slow)
pytest tests/ -m "not slow and not integration"
```

---

## 2. Linting & Formatting (Ruff)

### Standards

- Use **Ruff** as the primary linter and formatter (replaces flake8, isort, black, pyflakes, pycodestyle)
- If the project already uses flake8/black/isort, keep existing tools but suggest Ruff migration
- Line length: **120** characters
- Enable rules: `E`, `F`, `W`, `I` (isort), `N` (pep8-naming), `UP` (pyupgrade), `B` (bugbear), `SIM` (simplify), `RUF`
- Auto-fix safe issues; require manual review for unsafe fixes
- Format all code before committing

### Required Configuration

```toml
# pyproject.toml
[tool.ruff]
target-version = "py311"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "SIM", "RUF"]
ignore = ["E501"]  # line length handled by formatter
fixable = ["ALL"]
unfixable = []

[tool.ruff.lint.isort]
known-first-party = ["src"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### Commands

```bash
# Lint and report issues
ruff check .

# Lint and auto-fix safe issues
ruff check . --fix

# Format code
ruff format .

# Check formatting without modifying
ruff format . --check
```

---

## 3. Security Scanning

### 3a. Static Analysis — Bandit

Detects common security issues (SQL injection, hardcoded passwords, insecure functions, etc.)

```toml
# pyproject.toml
[tool.bandit]
exclude_dirs = ["tests", ".venv"]
skips = []  # add B101 to skip assert warnings in non-test code if needed
```

```bash
# Run bandit on source code
bandit -r src/ -c pyproject.toml

# Generate JSON report for CI
bandit -r src/ -f json -o bandit-report.json
```

### 3b. Dependency Vulnerability Scanning — pip-audit

Checks installed packages against known vulnerability databases (PyPI advisory DB, OSV).

```bash
# Scan current environment
pip-audit

# Scan from requirements file
pip-audit -r requirements.txt

# Output in JSON for CI integration
pip-audit --format json --output pip-audit-report.json
```

### 3c. Pattern-Based Analysis — Semgrep (optional, for advanced projects)

Detects language-specific vulnerabilities, OWASP patterns, and custom rules.

```bash
# Run with Python security ruleset
semgrep --config=p/python --config=p/owasp-top-ten src/

# Run with auto rules (recommended for CI)
semgrep --config=auto src/
```

---

## 4. Type Checking (mypy)

### Standards

- Use **mypy** in strict mode for new projects; gradual mode for brownfield
- All public functions must have type annotations
- Use `py.typed` marker for library packages

```toml
# pyproject.toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[[tool.mypy.overrides]]
module = ["tests.*"]
disallow_untyped_defs = false
```

```bash
# Run type checking
mypy src/
```

---

## 5. Integration with AIDLC Stages

### During Code Generation

When generating Python code:
1. Include type annotations on all public functions and class methods
2. Generate a corresponding `test_*.py` file for each module
3. Add `pyproject.toml` quality tool configuration (if not present)
4. Ensure generated code passes `ruff check` with zero errors
5. Include `conftest.py` fixtures for shared test dependencies

### During Build & Test

When creating build-and-test instructions for Python projects, include these quality gate steps:

```bash
# Step 1: Install dependencies
pip install -e ".[dev]"  # or: pip install -r requirements-dev.txt

# Step 2: Lint
ruff check .
ruff format . --check

# Step 3: Type check
mypy src/

# Step 4: Unit tests with coverage
pytest tests/ --cov --cov-report=term-missing --cov-fail-under=80

# Step 5: Security scan — static analysis
bandit -r src/

# Step 6: Security scan — dependency vulnerabilities
pip-audit
```

### CI Pipeline Template

When generating CI/CD configuration for Python projects, include:

```yaml
# Quality gate job template
quality-gates:
  steps:
    - run: pip install -e ".[dev]"
    - run: ruff check .
    - run: ruff format . --check
    - run: mypy src/
    - run: pytest tests/ --cov --cov-report=xml --cov-fail-under=80
    - run: bandit -r src/ -f json -o bandit-report.json
    - run: pip-audit --format json --output pip-audit-report.json
```

---

## 6. Dev Dependencies

When setting up a Python project, include these dev dependencies:

```toml
# pyproject.toml
[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=5.0",
    "pytest-mock>=3.12",
    "ruff>=0.5",
    "mypy>=1.10",
    "bandit>=1.7",
    "pip-audit>=2.7",
]
```

Or in `requirements-dev.txt`:
```
pytest>=8.0
pytest-cov>=5.0
pytest-mock>=3.12
ruff>=0.5
mypy>=1.10
bandit>=1.7
pip-audit>=2.7
```

---

## 7. Pre-commit Hooks (Recommended)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.5.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
        additional_dependencies: []

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.9
    hooks:
      - id: bandit
        args: ["-r", "src/"]
```

---

## Quality Gate Failure Policy

- **Linting errors**: Block — must be fixed before code generation is considered complete
- **Type errors**: Block for new code; warn for brownfield (gradual adoption)
- **Test failures**: Block — all tests must pass
- **Coverage below 80%**: Block — add tests for uncovered paths
- **Bandit HIGH/MEDIUM findings**: Block — must be resolved or explicitly suppressed with justification
- **pip-audit vulnerabilities**: Block for HIGH severity; warn for MEDIUM/LOW
- **Formatting**: Block — code must match `ruff format` output
