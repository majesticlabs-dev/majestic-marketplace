---
name: mermaid-builder
description: Expert guidance for creating syntactically correct and well-structured Mermaid diagrams following best practices. Use when creating flowcharts, sequence diagrams, class diagrams, state diagrams, Gantt charts, ER diagrams, or any other Mermaid visualization.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch, WebFetch
---

# Mermaid Builder

## Overview

This skill provides comprehensive guidance for creating syntactically correct, maintainable, and effective Mermaid diagrams. Apply these standards when creating any Mermaid diagram to ensure proper syntax, clarity, and adherence to best practices.

## Core Philosophy

Prioritize:
- **Correctness**: Follow Mermaid syntax rules strictly to avoid rendering errors
- **Clarity**: Diagrams should communicate complex ideas simply
- **Simplicity**: Avoid overloading diagrams with unnecessary detail
- **Maintainability**: Use comments and consistent styling for long-term maintenance
- **Modularity**: Break complex diagrams into subgraphs or separate diagrams

## Critical Syntax Rules

### Label Quoting Rule (Enforce)

**RULE: Wrap labels in double quotes if they contain spaces, special characters, or punctuation.**

```mermaid
flowchart LR
    %% CORRECT - labels with spaces are quoted
    A["User Login"] --> B["Process Request"]
    B --> C["Send Response"]

    %% CORRECT - simple labels without spaces
    Start --> Process --> End

    %% INCORRECT - spaces without quotes will fail
    A[User Login] --> B[Process Request]

    %% CORRECT - special characters quoted
    D["Pay $100?"] --> E["Confirm (Yes/No)"]

    %% CORRECT - punctuation quoted
    F["Step 1: Initialize"] --> G["Step 2: Process, Validate"]
```

**When to use quotes:**
- Contains spaces: `"User Login"` ✓ vs `User Login` ✗
- Contains special characters: `"Pay $100?"` ✓
- Contains punctuation: `"Confirm, please"` ✓
- Contains operators: `"(Admin)"` ✓
- Contains colons: `"Step 1: Initialize"` ✓

**When quotes are optional:**
- Simple alphanumeric: `A`, `Node1`, `Start`, `UserProfile` (no quotes needed)
- Single words: `Login`, `Process`, `End` (no quotes needed)

**Best practice:** When in doubt, use quotes. It never hurts to quote a label.

### Node Definitions

```mermaid
flowchart TD
    %% Basic shapes
    A["Rectangle"]
    B("Rounded Rectangle")
    C["Text in Box"]
    D{Decision}
    E[("Database")]
    F>"Flag Shape"]
    G[/"Parallelogram"/]
    H[\"Parallelogram Reverse"\]
    I[("Circle")]

    %% Node connections
    A --> B
    B --> C
    C --> D
    D -->|Yes| E
    D -->|No| F
```

### Edge Types

```mermaid
flowchart LR
    A["Node A"] --> B["Solid arrow"]
    A -.-> C["Dotted arrow"]
    A ==> D["Thick arrow"]
    A --- E["Solid line"]
    A -.- F["Dotted line"]
    A === G["Thick line"]
    A -->|Label| H["Arrow with label"]
    A -.->|Label| I["Dotted with label"]
```

### Comments

Always use comments to document complex flows:

```mermaid
flowchart TD
    %% This is a comment
    %% Multi-line comments help explain
    %% complex diagram sections

    Start["Start Process"]

    %% Authentication flow
    Start --> Auth["Authenticate"]
    Auth --> Check{Valid?}

    %% Success path
    Check -->|Yes| Process["Process Request"]

    %% Error path
    Check -->|No| Error["Show Error"]
```

## Diagram Types and When to Use

### 1. Flowchart (Most Common)

**Use for:** Processes, workflows, decision trees, algorithm flows

```mermaid
flowchart TD
    Start["Start"] --> Input["Get User Input"]
    Input --> Validate{Valid Input?}
    Validate -->|Yes| Process["Process Data"]
    Validate -->|No| Error["Show Error"]
    Process --> Save["Save to Database"]
    Save --> Success["Display Success"]
    Error --> Input
    Success --> End["End"]
```

**Direction options:**
- `TB` or `TD` - Top to Bottom
- `BT` - Bottom to Top
- `LR` - Left to Right
- `RL` - Right to Left

### 2. Sequence Diagram

**Use for:** Interactions between components, API flows, message passing

```mermaid
sequenceDiagram
    participant User
    participant Client
    participant Server
    participant Database

    User->>Client: "Click Submit"
    Client->>Server: "POST /api/data"
    activate Server
    Server->>Database: "Query Data"
    activate Database
    Database-->>Server: "Return Results"
    deactivate Database
    Server-->>Client: "200 OK"
    deactivate Server
    Client-->>User: "Display Success"
```

**Key elements:**
- `participant` - Define actors
- `->>` - Solid arrow (synchronous)
- `-->>` - Dotted arrow (response)
- `activate`/`deactivate` - Show activation bars

### 3. Class Diagram

**Use for:** Object-oriented system structure, database models

```mermaid
classDiagram
    class User {
        +String name
        +String email
        +Date created_at
        +login()
        +logout()
    }

    class Post {
        +String title
        +String content
        +Date published_at
        +publish()
        +archive()
    }

    class Comment {
        +String body
        +Date created_at
        +approve()
        +delete()
    }

    User "1" --> "*" Post : "creates"
    Post "1" --> "*" Comment : "has"
    User "1" --> "*" Comment : "writes"
```

**Relationships:**
- `<|--` - Inheritance
- `*--` - Composition
- `o--` - Aggregation
- `-->` - Association
- `..>` - Dependency

### 4. State Diagram

**Use for:** State transitions, finite state machines, status flows

```mermaid
stateDiagram-v2
    [*] --> Draft

    Draft --> InReview : "Submit"
    InReview --> Approved : "Approve"
    InReview --> Rejected : "Reject"
    Rejected --> Draft : "Revise"
    Approved --> Published : "Publish"
    Published --> Archived : "Archive"
    Archived --> [*]

    note right of InReview
        "Requires approval from
        authorized user"
    end note
```

### 5. Gantt Chart

**Use for:** Project timelines, scheduling, task dependencies

```mermaid
gantt
    title "Project Timeline"
    dateFormat YYYY-MM-DD

    section "Planning"
    "Requirements Gathering" :a1, 2025-01-01, 5d
    "Design Phase" :a2, after a1, 10d

    section "Development"
    "Backend API" :b1, after a2, 15d
    "Frontend UI" :b2, after a2, 20d

    section "Testing"
    "QA Testing" :c1, after b1, 10d
    "UAT" :c2, after c1, 5d
```

### 6. Entity-Relationship Diagram

**Use for:** Database schema design, data models

```mermaid
erDiagram
    USER ||--o{ ORDER : "places"
    ORDER ||--|{ ORDER_ITEM : "contains"
    PRODUCT ||--o{ ORDER_ITEM : "ordered_in"

    USER {
        int id PK
        string email
        string name
        datetime created_at
    }

    ORDER {
        int id PK
        int user_id FK
        datetime order_date
        decimal total
    }

    ORDER_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal price
    }

    PRODUCT {
        int id PK
        string name
        decimal price
        int stock
    }
```

**Cardinality:**
- `||--||` - One to one
- `||--o{` - One to many
- `}o--o{` - Many to many
- `||--|{` - One to exactly many

### 7. Pie Chart

**Use for:** Proportional data, percentage breakdown

```mermaid
pie title "User Distribution by Role"
    "Admin" : 10
    "Editor" : 25
    "Viewer" : 65
```

## Styling and Customization

### Define Custom Styles

```mermaid
flowchart TD
    A["Normal Node"]
    B["Success Node"]
    C["Error Node"]

    A --> B
    A --> C

    classDef successStyle fill:#90EE90,stroke:#006400,stroke-width:2px
    classDef errorStyle fill:#FFB6C1,stroke:#8B0000,stroke-width:2px

    class B successStyle
    class C errorStyle
```

### Subgraphs for Organization

```mermaid
flowchart TD
    subgraph "User Interface"
        A["Login Form"]
        B["Dashboard"]
        C["Profile Page"]
    end

    subgraph "API Layer"
        D["Auth Controller"]
        E["User Controller"]
    end

    subgraph "Database"
        F["Users Table"]
        G["Sessions Table"]
    end

    A --> D
    B --> E
    D --> F
    E --> F
    D --> G
```

## Common Syntax Errors to Avoid

### 1. Unquoted Labels with Spaces

```mermaid
%% WRONG - will fail to render
flowchart LR
    A[User Login] --> B[Process Request]

%% CORRECT - labels with spaces quoted
flowchart LR
    A["User Login"] --> B["Process Request"]
```

### 2. Unmatched Brackets

```mermaid
%% WRONG - missing closing bracket
flowchart LR
    A["Node --> B["Another Node"]

%% CORRECT - properly closed
flowchart LR
    A["Node"] --> B["Another Node"]
```

### 3. Invalid Edge Syntax

```mermaid
%% WRONG - invalid arrow
flowchart LR
    A -> B

%% CORRECT - use proper arrow syntax
flowchart LR
    A --> B
```

### 4. Missing Quotes in Labels with Special Characters

```mermaid
%% WRONG - special characters without quotes
flowchart LR
    A[Cost: $100] --> B[Discount (10%)]

%% CORRECT - special characters quoted
flowchart LR
    A["Cost: $100"] --> B["Discount (10%)"]
```

### 5. Inconsistent Node IDs

```mermaid
%% WRONG - Node1 defined twice with different shapes
flowchart LR
    Node1["First"] --> Node2["Second"]
    Node1("Different Shape")

%% CORRECT - unique IDs for each node
flowchart LR
    Node1["First"] --> Node2["Second"]
    Node3("Different Shape")
```

## Best Practices

### 1. Use Meaningful Node IDs

```mermaid
%% GOOD - descriptive IDs
flowchart TD
    UserLogin["User Login"] --> AuthCheck{Authenticate?}
    AuthCheck -->|Yes| Dashboard["Show Dashboard"]
    AuthCheck -->|No| LoginError["Show Error"]

%% AVOID - unclear IDs
flowchart TD
    A["User Login"] --> B{Authenticate?}
    B -->|Yes| C["Show Dashboard"]
    B -->|No| D["Show Error"]
```

### 2. Keep Diagrams Simple

Break complex diagrams into multiple smaller diagrams or use subgraphs:

```mermaid
flowchart TD
    subgraph "Input Layer"
        A["Receive Request"]
        B["Validate Input"]
    end

    subgraph "Processing Layer"
        C["Business Logic"]
        D["Data Transform"]
    end

    subgraph "Output Layer"
        E["Format Response"]
        F["Send Response"]
    end

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
```

### 3. Use Comments Liberally

```mermaid
flowchart TD
    %% User Authentication Flow
    %% Updated: 2025-01-15

    Start["Start"] --> Login["User Login"]

    %% Check credentials against database
    Login --> Auth{Valid Credentials?}

    %% Success path
    Auth -->|Yes| Token["Generate Token"]
    Token --> Success["Redirect to Dashboard"]

    %% Failure path - allow retry
    Auth -->|No| Error["Show Error"]
    Error --> Login
```

### 4. Consistent Styling

Use `classDef` for consistent appearance:

```mermaid
flowchart TD
    Start["Start"]
    Process1["Process Step"]
    Process2["Another Step"]
    Success["Success"]
    Error["Error"]

    Start --> Process1
    Process1 --> Process2
    Process2 --> Success
    Process1 --> Error

    classDef processStyle fill:#E3F2FD,stroke:#1976D2
    classDef successStyle fill:#C8E6C9,stroke:#388E3C
    classDef errorStyle fill:#FFCDD2,stroke:#D32F2F

    class Process1,Process2 processStyle
    class Success successStyle
    class Error errorStyle
```

### 5. Preview and Validate

Always preview your diagram before committing:
- Use online editors (mermaid.live)
- Check for syntax errors
- Verify labels display correctly
- Test in target environment

## Validation Checklist

Before finalizing any Mermaid diagram, verify:

- [ ] All labels with spaces are quoted
- [ ] All labels with special characters are quoted
- [ ] All labels with punctuation are quoted
- [ ] All brackets are properly matched
- [ ] Edge syntax is correct (-->, --->, etc.)
- [ ] Node IDs are unique and meaningful
- [ ] Comments explain complex sections
- [ ] Diagram direction is appropriate (TD, LR, etc.)
- [ ] Diagram type matches use case
- [ ] Styling is consistent across nodes
- [ ] Diagram is not overly complex
- [ ] Subgraphs are used for organization if needed
- [ ] No syntax errors when previewed

## Quick Reference

### Flowchart Shapes
- `["Rectangle"]` - Rectangle
- `("Rounded")` - Rounded rectangle
- `{"Diamond"}` - Diamond (decision)
- `[("Database")]` - Cylinder
- `(("Circle"))` - Circle
- `>"Flag"]` - Asymmetric
- `[/"Parallelogram"/]` - Parallelogram

### Common Arrow Types
- `-->` - Solid arrow
- `---` - Solid line
- `-.->` - Dotted arrow
- `-.-` - Dotted line
- `==>` - Thick arrow
- `===` - Thick line
- `-->|Label|` - Arrow with label

### Diagram Types
- `flowchart TD` - Flowchart top-down
- `sequenceDiagram` - Sequence diagram
- `classDiagram` - Class diagram
- `stateDiagram-v2` - State diagram
- `gantt` - Gantt chart
- `erDiagram` - ER diagram
- `pie` - Pie chart

## Resources

- Official Mermaid documentation: https://mermaid.js.org/
- Mermaid Live Editor: https://mermaid.live/
- Syntax reference: https://mermaid.js.org/intro/syntax-reference.html

## Common Patterns

### Decision Flow Pattern

```mermaid
flowchart TD
    Start["Start"] --> Input["Get Input"]
    Input --> Validate{Valid?}
    Validate -->|Yes| Process["Process"]
    Validate -->|No| Error["Show Error"]
    Error --> Input
    Process --> End["End"]
```

### Service Architecture Pattern

```mermaid
flowchart LR
    Client["Client"] --> Gateway["API Gateway"]
    Gateway --> Auth["Auth Service"]
    Gateway --> Users["User Service"]
    Gateway --> Orders["Order Service"]

    Users --> DB1[("User DB")]
    Orders --> DB2[("Order DB")]
    Auth --> Cache[("Redis Cache")]
```

### State Machine Pattern

```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Active : "activate"
    Active --> Suspended : "suspend"
    Suspended --> Active : "resume"
    Active --> Deleted : "delete"
    Suspended --> Deleted : "delete"
    Deleted --> [*]
```

Remember: **When in doubt about label syntax, always use double quotes. The quoting rule is the #1 cause of Mermaid rendering failures.**
