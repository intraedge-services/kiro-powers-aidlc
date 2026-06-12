# AIDLC Extensions

Extensions layer additional rules on top of the core AI-DLC workflow. They are opt-in (user chooses during Requirements Analysis) or always-enforced (no opt-in file).

## How Extensions Work

1. At workflow start, the agent scans this `extensions/` directory and loads only `*.opt-in.md` files
2. During Requirements Analysis, each opt-in prompt is presented to the user as a multiple-choice question
3. When the user opts in → the corresponding rules file is loaded and enforced as **blocking constraints**
4. When the user opts out → the rules file is never loaded
5. Extensions without a matching `*.opt-in.md` file are **always enforced**

## Extension Structure

Each extension consists of two files in the same directory:

```
extensions/<category>/<name>/
├── <name>.md              # The rules (blocking constraints with verification criteria)
└── <name>.opt-in.md       # User prompt presented during Requirements Analysis
```

## Rule Format

Rules in an extension file use this structure:

```markdown
## Rule <PREFIX-NN>: <Title>

### Rule
<Description of what must be done>

### Verification
<Concrete checks the agent evaluates at each stage>
```

- **PREFIX**: Short category identifier (e.g., `SEC`, `TEST`, `RES`)
- **NN**: Sequential number (e.g., `01`, `02`)
- Rule IDs must be unique across all loaded extensions

## Adding Your Own Extensions

1. Create a directory under `extensions/` (e.g., `compliance/baseline/`)
2. Add a rules file following the `## Rule PREFIX-NN:` format
3. Add a matching `.opt-in.md` file (omit for always-enforced extensions)
4. Rules are blocking by default — if verification fails, the stage cannot proceed until resolved

## Built-in Extensions

| Extension | Category | Description |
|-----------|----------|-------------|
| security-baseline | security | OWASP-aligned security practices for production applications |
| property-based-testing | testing | Property-based testing rules for robust test coverage |
| resiliency-baseline | resiliency | AWS Well-Architected Reliability Pillar best practices |
