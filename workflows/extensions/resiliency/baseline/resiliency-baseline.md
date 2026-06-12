# Resiliency Baseline Extension

When enabled, these rules apply directional, design-time best practices for building resilient systems. Derived from the AWS Well-Architected Framework (Reliability Pillar) and resilience-review guidance.

> **Important**: These rules are provided as directional best practices for building resilient workloads. Each organization should build, customize, and thoroughly test their own resiliency rules before deploying in production workflows.

---

## Rule RES-01: Define Availability Targets

### Rule
The system MUST have explicit availability targets (SLA/SLO) defined during requirements. Targets must specify: availability percentage, acceptable downtime window, recovery time objective (RTO), and recovery point objective (RPO).

### Verification
- [ ] Availability target is explicitly stated (e.g., 99.9%, 99.99%)
- [ ] Maximum acceptable downtime is quantified
- [ ] RTO is defined (how fast to recover)
- [ ] RPO is defined (how much data loss is acceptable)

---

## Rule RES-02: Failure Mode Analysis

### Rule
Each component and integration point MUST have identified failure modes with documented impact and mitigation strategy. Single points of failure MUST be eliminated or explicitly accepted with documented justification.

### Verification
- [ ] Each component lists its failure modes (crash, timeout, data corruption, resource exhaustion)
- [ ] Impact of each failure mode is documented (blast radius)
- [ ] Mitigation strategy exists for each failure mode
- [ ] Single points of failure are identified and either eliminated or explicitly accepted

---

## Rule RES-03: Retry and Timeout Patterns

### Rule
All remote calls (HTTP, database, queue, external service) MUST have explicit timeouts configured. Retries MUST use exponential backoff with jitter. Circuit breaker patterns MUST be used for dependencies that may become unavailable.

### Verification
- [ ] All remote calls have explicit timeout values (no infinite waits)
- [ ] Retry logic uses exponential backoff with jitter (not fixed intervals)
- [ ] Maximum retry count is bounded
- [ ] Circuit breaker is implemented for external dependencies

---

## Rule RES-04: Graceful Degradation

### Rule
The system MUST define degraded operating modes for when dependencies are unavailable. Critical user paths MUST continue functioning (possibly with reduced capability) when non-critical dependencies fail.

### Verification
- [ ] Degraded modes are defined for each external dependency failure
- [ ] Critical paths are identified and have fallback behavior
- [ ] Non-critical features fail silently without affecting core functionality
- [ ] Users are informed of degraded status (not left confused)

---

## Rule RES-05: Health Checks and Readiness

### Rule
Every service MUST expose health check endpoints that verify both liveness (process is running) and readiness (can serve traffic). Health checks MUST verify downstream dependency connectivity.

### Verification
- [ ] Liveness endpoint exists (process health)
- [ ] Readiness endpoint exists (can serve traffic, dependencies connected)
- [ ] Health checks verify downstream dependencies (database, cache, queues)
- [ ] Health check responses include version and dependency status

---

## Rule RES-06: Observability

### Rule
The system MUST implement the three pillars of observability: structured logging, distributed tracing, and metrics. Alerts MUST be configured for SLO breaches with defined escalation paths.

### Verification
- [ ] Structured logging with correlation IDs across services
- [ ] Distributed tracing spans critical request paths
- [ ] Key metrics are emitted (latency, error rate, throughput, saturation)
- [ ] SLO breach alerts are configured with escalation policy

---

## Rule RES-07: Data Durability

### Rule
Data MUST be replicated or backed up commensurate with the defined RPO. Backup restoration MUST be tested. Data integrity checks MUST be implemented for critical data paths.

### Verification
- [ ] Backup strategy meets defined RPO
- [ ] Backups are stored in a separate failure domain (different AZ/region)
- [ ] Backup restoration is documented and tested
- [ ] Data integrity validation exists (checksums, consistency checks)

---

## Rule RES-08: Capacity Planning

### Rule
The system MUST have defined scaling triggers and capacity limits. Auto-scaling MUST be configured where applicable. Load testing MUST validate that the system handles expected peak load plus headroom.

### Verification
- [ ] Scaling triggers are defined (CPU, memory, queue depth, request count)
- [ ] Auto-scaling is configured for variable workloads
- [ ] Capacity limits are documented (max connections, max throughput)
- [ ] Load testing validates peak + 20% headroom

---

## Rule RES-09: Deployment Safety

### Rule
Deployments MUST be reversible (rollback within RTO). Blue-green or canary deployment strategies MUST be used for critical services. Deployment MUST NOT require downtime for stateless services.

### Verification
- [ ] Rollback procedure is documented and tested
- [ ] Rollback can complete within defined RTO
- [ ] Blue-green or canary deployment is configured for critical paths
- [ ] Zero-downtime deployment for stateless services

---

## Rule RES-10: Blast Radius Limitation

### Rule
The system MUST be designed to limit the blast radius of failures. Use cell-based architecture, bulkheads, or isolation boundaries to prevent cascading failures across components.

### Verification
- [ ] Components are isolated (failure in one doesn't cascade to others)
- [ ] Resource pools are isolated (separate thread pools, connection pools)
- [ ] Queue processing is bounded (won't consume all resources on spike)
- [ ] Multi-tenant systems have tenant isolation

---

## Enforcement

These rules are checked at the following AIDLC stages:

| Stage | Rules Checked |
|-------|--------------|
| Requirements Analysis | RES-01 (availability targets must be defined) |
| Functional Design | RES-02, RES-04 (failure modes, degradation) |
| NFR Requirements | All RES rules |
| NFR Design | RES-03, RES-04, RES-05, RES-06, RES-08, RES-10 |
| Infrastructure Design | RES-05, RES-07, RES-08, RES-09, RES-10 |
| Code Generation | RES-03, RES-04, RES-05, RES-06 |
| Build and Test | RES-08, RES-09 |

At each stage, the agent MUST verify applicable rules before allowing the stage to complete. If any rule fails verification, the finding must be resolved before proceeding.
