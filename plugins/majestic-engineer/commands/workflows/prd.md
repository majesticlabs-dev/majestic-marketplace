---
name: prd
description: Create a Product Requirements Document (PRD) for a new product or feature
argument-hint: "[product or feature description]"
---

# Create a Product Requirements Document (PRD)

Generate a comprehensive PRD that defines WHAT to build and WHY, with clear user stories, acceptance criteria, and success metrics.

## Product/Feature Description

<product_description>
$ARGUMENTS
</product_description>

## Phase 1: Clarifying Questions

Before generating the PRD, ask the user 3-5 essential clarifying questions. Use this numbered format with lettered options for easy response:

<thinking>
Analyze the product description to identify gaps in understanding. Focus on questions that would significantly impact the PRD's clarity. Only ask questions when the answer isn't reasonably inferable from the description.
</thinking>

**Format your questions like this:**

```
1. What is the primary problem this solves?
   A. [Specific problem option]
   B. [Another problem option]
   C. [Third option]
   D. Other (please specify)

2. Who is the primary user?
   A. [User type option]
   B. [Another user type]
   C. [Third option]
   D. Other (please specify)
```

**Question areas to consider (pick 3-5 most critical):**

- **Problem/Goal**: What problem does this solve? What's the primary outcome?
- **Target Users**: Who will use this? What are their technical levels?
- **Scope Boundaries**: What should this explicitly NOT do? MVP vs full vision?
- **Success Criteria**: How will we measure success? What metrics matter?
- **Technical Context**: Any existing systems to integrate with? Constraints?
- **Priority Features**: What's the single most important capability?

**IMPORTANT:** Wait for user responses before proceeding to Phase 2.

---

## Phase 2: Generate Balanced PRD

After receiving answers, generate the PRD using this structure:

### PRD Template

```markdown
# PRD: [Feature/Product Name]

## 1. Overview

- **Version**: 1.0
- **Date**: [Today's date]
- **Author**: [User or team name if known]
- **Status**: Draft

### Problem Statement

[2-3 paragraphs describing the problem, who experiences it, and why it matters]

### Target Users

[Brief description of primary users and their context]

---

## 2. Goals & Non-Goals

### Business Goals

- [Goal 1]
- [Goal 2]
- [Goal 3]

### User Goals

- [What users want to achieve]
- [Pain points being addressed]

### Non-Goals (Out of Scope)

- [Explicit boundary 1] - *Rationale: [why excluded]*
- [Explicit boundary 2] - *Rationale: [why excluded]*

---

## 3. User Personas

### Key User Types

- **[Persona Name]**: [Brief description, needs, technical level]
- **[Persona Name]**: [Brief description, needs, technical level]

### Role-Based Access

| Role | Permissions | Key Actions |
|------|-------------|-------------|
| [Role] | [Access level] | [What they can do] |

---

## 4. User Stories

### US-001: [Story Title]

- **As a** [role]
- **I want** [capability]
- **So that** [value/benefit]

**Acceptance Criteria:**
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]
- [ ] [Edge case handling]

### US-002: [Story Title]

[Continue pattern for all user stories...]

**Include for each feature area:**
- At least 1 happy path scenario
- At least 1 edge case or error scenario

---

## 5. Functional Requirements

### FR-001: [Feature Name] (Priority: High)

- [Requirement detail]
- [Requirement detail]
- **Dependencies**: [Any dependencies]

### FR-002: [Feature Name] (Priority: Medium)

[Continue pattern...]

---

## 6. User Experience

### Entry Points & First-Time Flow

1. [How users discover/access the feature]
2. [First-time user experience]
3. [Onboarding considerations]

### Core Experience

| Step | Action | System Response | Success State |
|------|--------|-----------------|---------------|
| 1 | [User action] | [What happens] | [Expected outcome] |
| 2 | [User action] | [What happens] | [Expected outcome] |

### Edge Cases & Error States

- **[Scenario]**: [How it's handled]
- **[Error condition]**: [User feedback and recovery path]

---

## 7. Technical Considerations

### Integration Points

- [System/API to integrate with]
- [Data sources]

### Data Storage & Privacy

- [What data is stored]
- [Privacy considerations]
- [Retention requirements]

### Performance Requirements

- [Response time expectations]
- [Scale considerations]

### Potential Challenges

- [Technical challenge 1]
- [Technical challenge 2]

---

## 8. Success Metrics

### User-Centric Metrics

- [Metric]: [Target] - *How measured*
- [Metric]: [Target] - *How measured*

### Technical Metrics

- [Metric]: [Target] - *How measured*

---

## 9. Milestones

### Estimated Complexity

**[Small/Medium/Large]**: [Brief rationale]

### Suggested Phases

#### Phase 1: [Name] (Est: [timeframe])
- [ ] [Key deliverable]
- [ ] [Key deliverable]

#### Phase 2: [Name] (Est: [timeframe])
- [ ] [Key deliverable]
- [ ] [Key deliverable]

---

## 10. Open Questions

- [ ] [Question needing stakeholder input]
- [ ] [Unresolved decision]
```

---

## Phase 3: Review & Expansion Offer

After generating the balanced PRD:

1. **Save the file** to `docs/prd/prd-[feature-name].md`
2. **Present summary** of what was created
3. **Ask the user**:

```
PRD created at: docs/prd/prd-[feature-name].md

Would you like me to expand this PRD with additional technical depth?

**Technical expansion includes:**
- API Specifications (endpoints, schemas, auth)
- Data Model with Mermaid ERD diagram
- Security Considerations (AuthN/AuthZ, OWASP mapping)
- Performance & Scalability details (SLOs, scaling strategy)

Reply with:
- **"expand"** to add technical sections
- **"done"** if the balanced PRD is sufficient
- Or provide feedback on specific sections to revise
```

---

## Phase 4: Full Technical Expansion (If Requested)

If user requests expansion, add these sections to the PRD:

```markdown
---

## 11. API Specifications

### [Endpoint Name]

- **Method & Path**: `POST /api/v1/[resource]`
- **Purpose**: [What it does]
- **Auth**: [Scheme, required scopes/roles]

**Request Body:**
```json
{
  "field": "type (constraints)"
}
```

**Response (200):**
```json
{
  "field": "type"
}
```

**Errors:**
| Code | Message | Remediation |
|------|---------|-------------|
| 400 | [Error] | [How to fix] |
| 401 | [Error] | [How to fix] |

---

## 12. Data Model

### Entity Relationship Diagram

```mermaid
erDiagram
    EntityA ||--o{ EntityB : "has many"
    EntityA {
        uuid id PK
        string name
        timestamp created_at
    }
    EntityB {
        uuid id PK
        uuid entity_a_id FK
        string status
    }
```

### Entity Details

| Entity | Attribute | Type | Constraints | Notes |
|--------|-----------|------|-------------|-------|
| [Name] | [attr] | [type] | [PK/FK/index] | [PII?] |

### Data Lifecycle

- **Retention**: [Policy]
- **Deletion**: [Soft/hard delete approach]
- **Archival**: [Strategy]

---

## 13. Security Considerations

### Authentication & Authorization

| Role | Permissions | Access Level |
|------|-------------|--------------|
| [Role] | [What they can do] | [Scope] |

### Data Protection

- **In Transit**: [TLS version, etc.]
- **At Rest**: [Encryption approach]
- **Secrets Management**: [Approach]

### OWASP Top 10 Mapping

| Threat | Mitigation |
|--------|------------|
| Injection | [Approach] |
| Broken Auth | [Approach] |
| [Relevant threats...] | [Approach] |

---

## 14. Performance & Scalability

### SLOs/SLIs

| Metric | Target | Measurement |
|--------|--------|-------------|
| Latency (p95) | [target] | [how measured] |
| Availability | [target] | [how measured] |
| Throughput | [target] | [how measured] |

### Scaling Strategy

- **Horizontal**: [Approach]
- **Vertical**: [Limits]
- **Caching**: [Strategy, TTL, invalidation]
- **Rate Limiting**: [Approach]
```

---

## Best Practices Applied

This PRD format follows industry best practices:

- **Clear, actionable language** - Specific requirements, not vague descriptions
- **User story IDs** - Traceable requirements (US-001, FR-001)
- **Testable acceptance criteria** - Measurable success conditions
- **Explicit scope boundaries** - Non-goals prevent scope creep
- **Balanced depth** - Comprehensive without overwhelming
- **Developer-ready** - Empowers "how" decisions while defining "what"

## Output

Save the final PRD to: `docs/prd/prd-[feature-name].md`

If the directory doesn't exist, create it first.
