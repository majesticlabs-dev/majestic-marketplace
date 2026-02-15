# Data Lineage Visualization Patterns

## Simple Data Pipeline Pattern

**Use for:** ETL processes, data transformations, single-direction flows

```mermaid
flowchart LR
    %% Data Sources
    Source1[("Source DB")] --> Extract["Extract"]
    Source2[("API")] --> Extract
    Source3[("CSV Files")] --> Extract

    %% Transformation Layer
    Extract --> Transform["Transform & Clean"]
    Transform --> Enrich["Enrich Data"]
    Enrich --> Validate{Valid?}

    %% Error Handling
    Validate -->|No| ErrorLog[("Error Log")]
    ErrorLog --> ManualReview["Manual Review"]
    ManualReview --> Transform

    %% Success Path
    Validate -->|Yes| Load["Load to Warehouse"]
    Load --> Target[("Data Warehouse")]

    classDef sourceStyle fill:#E3F2FD,stroke:#1976D2
    classDef processStyle fill:#FFF9C4,stroke:#F57F17
    classDef targetStyle fill:#C8E6C9,stroke:#388E3C
    classDef errorStyle fill:#FFCDD2,stroke:#D32F2F

    class Source1,Source2,Source3 sourceStyle
    class Extract,Transform,Enrich,Load processStyle
    class Target targetStyle
    class ErrorLog,ManualReview errorStyle
```

## Multi-Layer Data Architecture

```mermaid
flowchart TD
    subgraph "Source Layer"
        S1[("CRM DB")]
        S2[("ERP DB")]
        S3[("Web Events")]
    end

    subgraph "Ingestion Layer"
        I1["CDC Connector"]
        I2["Batch Import"]
        I3["Stream Processor"]
    end

    subgraph "Raw Data Lake"
        R1[("Raw JSON")]
        R2[("Raw Parquet")]
    end

    subgraph "Transformation Layer"
        T1["Clean & Normalize"]
        T2["Join & Aggregate"]
    end

    subgraph "Curated Layer"
        C1[("Fact Tables")]
        C2[("Dimension Tables")]
    end

    subgraph "Consumption Layer"
        D1["BI Dashboard"]
        D2["ML Models"]
    end

    S1 --> I1 --> R1
    S2 --> I2 --> R2
    S3 --> I3 --> R1

    R1 --> T1
    R2 --> T1
    T1 --> T2

    T2 --> C1
    T2 --> C2

    C1 --> D1
    C2 --> D1
    C1 --> D2
```

## Cross-System Data Flow (Sequence)

```mermaid
sequenceDiagram
    participant Source as Source System
    participant Queue as Message Queue
    participant ETL as ETL Service
    participant DWH as Data Warehouse
    participant Cache as Redis Cache

    Source->>Queue: Publish event (real-time)
    activate Queue
    Queue->>ETL: Consume event
    deactivate Queue
    activate ETL

    ETL->>ETL: Transform & enrich
    ETL->>DWH: Batch insert (every 5 min)
    activate DWH
    DWH-->>ETL: Acknowledge
    deactivate DWH

    ETL->>Cache: Update aggregates
    deactivate ETL
```

## Database Schema Lineage (ER Diagram)

```mermaid
erDiagram
    RAW_EVENTS ||--o{ CLEANED_EVENTS : "cleaned_from"
    CLEANED_EVENTS ||--o{ USER_FACTS : "aggregated_into"
    CLEANED_EVENTS ||--o{ PRODUCT_FACTS : "aggregated_into"

    USER_DIMENSION ||--o{ USER_FACTS : "enriches"
    PRODUCT_DIMENSION ||--o{ PRODUCT_FACTS : "enriches"

    RAW_EVENTS {
        bigint id PK
        timestamp event_time
        json payload
    }

    CLEANED_EVENTS {
        bigint id PK
        bigint raw_event_id FK
        string user_id
        decimal amount
    }

    USER_FACTS {
        string user_id PK
        date date PK
        decimal total_amount
    }
```

## Streaming Data Lineage (Kafka/Kinesis)

```mermaid
flowchart LR
    subgraph "Producers"
        P1["Web Events"]
        P2["Mobile Events"]
    end

    subgraph "Streaming Platform"
        T1["Topic: raw_events<br/>Partitions: 12"]
        T2["Topic: enriched_events"]
    end

    subgraph "Stream Processors"
        SP1["Enrichment"]
        SP2["Anomaly Detection"]
    end

    subgraph "Sinks"
        Sink1[("S3 Data Lake")]
        Sink2[("Elasticsearch")]
    end

    P1 --> T1
    P2 --> T1
    T1 --> SP1
    T1 --> SP2
    SP1 --> T2
    T1 -.->|Archive| Sink1
    T2 --> Sink2
```

## Column-Level Lineage

```mermaid
flowchart TD
    subgraph "Source Tables"
        S1["orders.order_total"]
        S2["orders.customer_id"]
        S3["customers.customer_name"]
    end

    subgraph "Transformations"
        T1["JOIN ON customer_id"]
        T2["SUM(order_total)"]
        T3["UPPER(customer_name)"]
    end

    subgraph "Target: customer_summary"
        D1["customer_id"]
        D2["customer_name_upper"]
        D3["total_orders"]
    end

    S2 --> T1 --> D1
    S1 --> T2 --> D3
    S3 --> T3 --> D2
```

## Best Practices

1. **Show directionality** - Data flows left-to-right or top-to-bottom
2. **Include metadata** - Record counts, refresh frequency, retention
3. **Highlight transformations** - Make it obvious where data changes
4. **Use consistent styling** - Sources, processes, targets have distinct colors
5. **Add quality checks** - Show validation points and error handling
6. **Document timing** - Batch intervals, streaming latency
7. **Keep focused** - Break complex pipelines into multiple diagrams
