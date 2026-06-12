# Security Baseline Extension

When enabled, these rules are enforced as blocking constraints at every applicable AIDLC stage. Each rule must pass verification before the stage can proceed.

> **Important**: These rules are provided as a directional reference for building effective security rules within AI-DLC workflows. Each organization should build, customize, and thoroughly test their own security rules before deploying in production workflows.

---

## Rule SEC-01: Input Validation

### Rule
All user inputs, API parameters, file uploads, and external data MUST be validated before processing. Validation must include type checking, length limits, format validation, and sanitization against injection attacks.

### Verification
- [ ] Every endpoint/function accepting external input has explicit validation
- [ ] Input length limits are defined and enforced
- [ ] Input format is validated (regex, schema, or type assertion)
- [ ] No raw user input is passed directly to SQL, shell commands, or template engines

---

## Rule SEC-02: Authentication and Authorization

### Rule
All protected resources MUST require authentication. Authorization checks MUST be performed at the resource level, not just at the route/endpoint level. Use principle of least privilege.

### Verification
- [ ] Protected endpoints require valid authentication tokens/sessions
- [ ] Authorization is checked per-resource, not just per-route
- [ ] Default access is denied (allowlist approach)
- [ ] No hardcoded credentials or API keys in source code

---

## Rule SEC-03: Secrets Management

### Rule
Secrets (API keys, passwords, tokens, certificates) MUST NOT be stored in source code, configuration files committed to version control, or environment variable defaults. Use a secrets manager or secure vault.

### Verification
- [ ] No secrets in source code or committed config files
- [ ] Environment variables are used for runtime secrets (not committed defaults)
- [ ] Secrets manager integration exists for production environments
- [ ] `.gitignore` covers files that may contain secrets (`.env`, `*.pem`, etc.)

---

## Rule SEC-04: Data Protection in Transit

### Rule
All data transmitted over networks MUST use TLS 1.2+ encryption. Internal service-to-service communication MUST also be encrypted. Certificate validation MUST NOT be disabled.

### Verification
- [ ] All HTTP endpoints use HTTPS (no plain HTTP in production)
- [ ] TLS 1.2 or higher is enforced (no SSLv3, TLS 1.0, TLS 1.1)
- [ ] Certificate validation is not disabled (`verify=False`, `rejectUnauthorized: false`)
- [ ] Internal service communication uses mTLS or equivalent

---

## Rule SEC-05: Data Protection at Rest

### Rule
Sensitive data at rest MUST be encrypted using industry-standard algorithms (AES-256 or equivalent). Encryption keys MUST be managed through a key management service.

### Verification
- [ ] Database storage uses encryption at rest (e.g., AWS KMS, RDS encryption)
- [ ] S3 buckets (or equivalent storage) have default encryption enabled
- [ ] Encryption keys are managed via KMS or equivalent (not hardcoded)
- [ ] Backup data is also encrypted

---

## Rule SEC-06: Logging and Monitoring

### Rule
Security-relevant events MUST be logged with sufficient detail for incident investigation. Logs MUST NOT contain sensitive data (passwords, tokens, PII). Logging must be tamper-resistant.

### Verification
- [ ] Authentication events (login, logout, failures) are logged
- [ ] Authorization failures are logged
- [ ] Logs do not contain passwords, tokens, or raw PII
- [ ] Log storage is protected from tampering (write-once or integrity-verified)

---

## Rule SEC-07: Dependency Security

### Rule
All dependencies MUST be from trusted sources with pinned versions. Known vulnerabilities in dependencies MUST be identified and remediated. Dependency updates should be automated.

### Verification
- [ ] Dependencies use pinned/locked versions (lockfile exists)
- [ ] No dependencies from untrusted or unknown sources
- [ ] Vulnerability scanning is configured (pip-audit, npm audit, etc.)
- [ ] Critical/High vulnerabilities are not present in current dependencies

---

## Rule SEC-08: Error Handling

### Rule
Error responses MUST NOT expose internal system details (stack traces, database schemas, file paths, internal IPs). Use generic error messages for external consumers while logging full details internally.

### Verification
- [ ] Error responses to clients are generic (no stack traces, no internal paths)
- [ ] Detailed error information is logged server-side only
- [ ] Exception handling covers all external-facing code paths
- [ ] No debug mode enabled in production configurations

---

## Enforcement

These rules are checked at the following AIDLC stages:

| Stage | Rules Checked |
|-------|--------------|
| Functional Design | SEC-01, SEC-02, SEC-03 |
| NFR Requirements | All SEC rules |
| NFR Design | All SEC rules |
| Infrastructure Design | SEC-03, SEC-04, SEC-05, SEC-06, SEC-07 |
| Code Generation | All SEC rules |
| Build and Test | SEC-07, SEC-08 |

At each stage, the agent MUST verify applicable rules before allowing the stage to complete. If any rule fails verification, the finding must be resolved before proceeding.
