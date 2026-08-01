# Knowledge Base — <requirement-name>

> Shared knowledgebase for the Requirement-to-QA workflow.
> **Append-only rule:** every agent copies this file into its own subfolder and updates ONLY its own sections. Never delete or rewrite another agent's content. Always date-stamp additions. When in doubt, append rather than replace.
> Current sections are fixed — do not renumber or rename them. Content may be extended within a section.

---

## 1. References & Sources
_Who owns: ReqGateAgent._ List of references provided by the user (repo path, wiki/flow/Jira URLs, existing KB, or "no reference") and where they were scanned / what was found.

- (empty)

## 2. Questions Asked & Answers
_Who owns: ReqGateAgent._ Full Q&A transcript from requirement gathering (and any later clarification rounds). Include question, answer, who asked, date.

- (empty)

## 3. Requirements & Scope
_Who owns: ReqGateAgent._ Final agreed requirements, explicitly stated scope (what is IN scope) and explicit non-goals (what is OUT of scope). Acceptance criteria / definition of done. **Tech stack decision** (backend/frontend/build/test) agreed with the user during requirement gathering.

- (empty)

## 4. Assumptions & Decisions
_Who owns: everyone (date-stamped)._ Every assumption made and every decision taken across the pipeline. Decisions must note who confirmed them (user / agent) and when.

- (empty)

## 5. HLD / Architecture
_Who owns: HLDAgent._ Final HLD decisions: services/microservices, their interactions, storage (SQL/NoSQL) & cache layers, sync (REST/gRPC) vs async (Kafka/RabbitMQ/SQS) communication, event-driven vs API flows. Pointer to the final HLD html.

- (empty)

## 6. Flows (with inclusion & exclusion)
_Who owns: FlowsIdentifierAgent._ Each flow: name, summary, what it covers (inclusion), what it does NOT cover (exclusion), and any cross-flow dependencies.

- (empty)

## 7. Test Cases
_Who owns: TestGeneratorAgent._ Per flow: agreed inputs and expected outputs, Sanity and Regression case references (files saved in TestGeneratorAgent folder).

- (empty)

## 8. LLD, Spec & Plans
_Who owns: Implementation agents (LLD, Spec Writer, Planner)._ Per flow: sequence diagram decisions, spec decisions, implementation plan. Note any later-flow changes that forced re-work of an earlier flow.

- (empty)

## 9. Integration Status
_Who owns: IntegrationAgent._ Branch state, merge results, cross-flow connectors added, build/deploy status, .env configuration, sanity outcome after deploy. Pointer to the persisted `runbook.md` (startup commands, .env layout, health endpoints) that QA/Dev must reuse.

- (empty)

## 10. QA Results & Bugs
_Who owns: QAAgent._ Results of every QA round: tests run, pass/fail per test, logs for failures, and any tests the user chose to EXCLUDE permanently (recorded so later rounds honor the exclusion).

- (empty)

## 11. Fixes & Validation
_Who owns: DevAgent._ For each bug fixed: what changed, which test was re-validated, commit/rebase/push state.

- (empty)

## 12. Open Items & Escalations
_Who owns: everyone._ Anything blocked, needing user decision, or escalated. Must be resolved or explicitly closed before the workflow is considered done.

- (empty)
