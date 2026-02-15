# Diagram Type Examples

## Flowchart

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

**Direction options:** `TB`/`TD` (top-down), `BT` (bottom-up), `LR` (left-right), `RL` (right-left)

## Sequence Diagram

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

**Key elements:** `participant`, `->>` (solid), `-->>` (response), `activate`/`deactivate`

## Class Diagram

```mermaid
classDiagram
    class User {
        +String name
        +String email
        +login()
        +logout()
    }

    class Post {
        +String title
        +String content
        +publish()
    }

    User "1" --> "*" Post : "creates"
```

**Relationships:** `<|--` (inheritance), `*--` (composition), `o--` (aggregation), `-->` (association)

## State Diagram

```mermaid
stateDiagram-v2
    [*] --> Draft

    Draft --> InReview : "Submit"
    InReview --> Approved : "Approve"
    InReview --> Rejected : "Reject"
    Rejected --> Draft : "Revise"
    Approved --> Published : "Publish"
    Published --> [*]
```

## Gantt Chart

```mermaid
gantt
    title "Project Timeline"
    dateFormat YYYY-MM-DD

    section "Planning"
    "Requirements" :a1, 2025-01-01, 5d
    "Design" :a2, after a1, 10d

    section "Development"
    "Backend" :b1, after a2, 15d
    "Frontend" :b2, after a2, 20d

    section "Testing"
    "QA" :c1, after b1, 10d
```

## Entity-Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ ORDER : "places"
    ORDER ||--|{ ORDER_ITEM : "contains"
    PRODUCT ||--o{ ORDER_ITEM : "ordered_in"

    USER {
        int id PK
        string email
        string name
    }

    ORDER {
        int id PK
        int user_id FK
        decimal total
    }
```

**Cardinality:** `||--||` (one-to-one), `||--o{` (one-to-many), `}o--o{` (many-to-many)

## Pie Chart

```mermaid
pie title "User Distribution by Role"
    "Admin" : 10
    "Editor" : 25
    "Viewer" : 65
```

## Styling with classDef

```mermaid
flowchart TD
    A["Normal"] --> B["Success"]
    A --> C["Error"]

    classDef successStyle fill:#90EE90,stroke:#006400,stroke-width:2px
    classDef errorStyle fill:#FFB6C1,stroke:#8B0000,stroke-width:2px

    class B successStyle
    class C errorStyle
```

## Subgraphs for Organization

```mermaid
flowchart TD
    subgraph "User Interface"
        A["Login Form"]
        B["Dashboard"]
    end

    subgraph "API Layer"
        C["Auth Controller"]
        D["User Controller"]
    end

    subgraph "Database"
        E["Users Table"]
    end

    A --> C
    B --> D
    C --> E
    D --> E
```
