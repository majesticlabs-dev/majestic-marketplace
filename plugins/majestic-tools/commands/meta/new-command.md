# New Command Builder `/new-command`

Generate any Claude Code command with production-quality patterns, real-world integrations, and intelligent features that make developers feel like they have superpowers.

## Arguments
- `[command-idea]` - Description of the command you want to create
- `[--style]` - Generation style:
  - `expert` - Like k8s-expert: multiple modes, deep analysis [default]
  - `interactive` - Heavy user interaction and guided flows
  - `autonomous` - Minimal interaction, maximum automation
  - `learning` - Builds knowledge over time
- `[--complexity]` - Target complexity:
  - `simple` - Single purpose, <100 lines
  - `standard` - Multiple features, <300 lines
  - `advanced` - Full expert system, 300+ lines [default]
- `[--location]` - Folder Location of the command
  - `project` - Create command in project level `.claude/commands/` [default]
  - `user` - Create command in user level `~/.claude/commands`

## Example Usage
```bash
# Generate a database optimization command
claude /new-command "optimize postgres databases"

# Create an interactive debugging assistant
claude /new-command "debug microservices" --style interactive

# Build a learning code reviewer
claude /new-command "review code like senior dev" --style learning
```

## Meta-Prompt for Command Generation

You are an expert AI creating Claude Code commands that rival the sophistication of the k8s-expert example. Every command you generate must feel like having a senior expert on call 24/7.

### 🎯 Core Requirements

1. **Multiple Action Modes** - Never create single-purpose commands
   ```markdown
   ## Arguments
   - `[action]` - Primary action:
     - `analyze` - Deep analysis with visualizations
     - `optimize` - Performance improvements
     - `fix` - Automated remediation
     - `monitor` - Continuous watching
     - `report` - Multi-audience outputs
   ```

2. **Real, Working Code** - Every example must be executable
   ```bash
   # ❌ BAD: Placeholder
   run_analysis_tool --analyze

   # ✅ GOOD: Actual commands
   docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | \
     awk 'NR>1 && $2+0 > 80 {print "High CPU: " $1 " at " $2}'
   ```

3. **Intelligent Recommendations** - Prioritized, actionable insights
   ```markdown
   ## Priority 1: Critical Issues 🔴
   ### Database Connection Pool Exhaustion
   **Impact**: 500 errors for 30% of requests
   **Root Cause**: Leaked connections from error paths
   **Fix Command**:
   \```bash
   # Immediate mitigation
   kubectl exec -it postgres-0 -- psql -c "SELECT pg_terminate_backend(pid)
     FROM pg_stat_activity WHERE state = 'idle' AND state_change < now() - interval '5 minutes';"

   # Permanent fix
   sed -i 's/pool_size=100/pool_size=200/' config/database.yml
   sed -i '/rescue StandardError/a\    ensure\n      connection&.close' app/models/*.rb
   \```
   ```

4. **Interactive Intelligence** - Guide users to optimal solutions
   ```markdown
   🤔 I've detected 3 different issues. Let's focus on the highest impact:

   1. 🔴 Memory leak in worker processes (causing OOM every 6 hours)
   2. 🟡 Inefficient database queries (3 N+1 patterns found)
   3. 🟢 Missing indexes (would improve performance by ~20%)

   Which would you like to tackle first? [1-3] or 'all' for automated fixes: _
   ```

5. **Visual Outputs** - Always include diagrams/charts
   ```mermaid
   graph LR
     subgraph "Before Optimization"
       A[Request] --> B[Load Balancer]
       B --> C["App Server<br/>CPU: 85%"]
       C --> D["(Database<br/>Connections: 95/100)"]
     end

     subgraph "After Optimization"
       E[Request] --> F[Load Balancer]
       F --> G["App Server<br/>CPU: 45%"]
       G --> H["(Database<br/>Connections: 30/200)"]
     end

     style C fill:#ff6b6b
     style D fill:#ff6b6b
     style G fill:#51cf66
     style H fill:#51cf66
   ```

### 🧠 Advanced Patterns to Include

#### Pattern 1: Progressive Disclosure
```bash
# Simple usage for beginners
claude /project:your-command

# Power user with full control
claude /project:your-command analyze --depth=comprehensive --fix-mode=auto --output=json,html,slack
```

#### Pattern 2: Learning & Memory
```yaml
# .claude/memory/your-command-patterns.yml
learned_patterns:
  - pattern: "Exception in UserService.authenticate"
    frequency: 15
    last_seen: 2024-01-19
    typical_cause: "Redis connection timeout"
    successful_fixes:
      - "Increased connection pool size"
      - "Added circuit breaker"

  - pattern: "Slow query in reports"
    frequency: 8
    typical_cause: "Missing compound index"
    auto_fix_confidence: 0.95
```

#### Pattern 3: Multi-Tool Orchestration
```bash
# Coordinate multiple tools for comprehensive analysis
analyze_system() {
  # Collect metrics from multiple sources
  prometheus_data=$(curl -s "$PROMETHEUS/api/v1/query?query=up")
  datadog_metrics=$(dog metric query "avg:system.cpu.user{*}")
  newrelic_traces=$(newrelic apm deployment list)

  # Correlate events
  correlation_window=300  # 5 minutes
  find_correlated_events "$prometheus_data" "$datadog_metrics" "$newrelic_traces"

  # Generate unified report
  generate_insight_report
}
```

#### Pattern 4: Safe Automation with Rollbacks
```bash
# Every change must be reversible
apply_optimization() {
  change_id=$(date +%s)

  # Snapshot current state
  kubectl get deployment $1 -o yaml > "/tmp/rollback-$change_id.yaml"

  # Apply change
  kubectl patch deployment $1 --patch "$2"

  # Monitor for 60 seconds
  if monitor_health $1 60; then
    echo "✅ Optimization successful"
    echo "Rollback available: kubectl apply -f /tmp/rollback-$change_id.yaml"
  else
    echo "❌ Optimization failed, rolling back..."
    kubectl apply -f "/tmp/rollback-$change_id.yaml"
  fi
}
```

### 📊 Required Sections for Every Command

1. **Workflow Steps** (minimum 6 steps)
   - Initialize & Verify Access
   - Discovery & Inventory
   - Analysis (action-specific)
   - Generate Recommendations
   - Interactive Decision Points
   - Execute & Verify
   - Generate Reports

2. **Multiple Output Formats**
   ```bash
   # Human-readable
   ./report-human.md

   # Machine-parseable
   ./report-data.json

   # Visual dashboard
   ./report-dashboard.html

   # Team communication
   ./report-slack-summary.txt
   ```

3. **Configuration File**
   ```yaml
   command_name:
     # Behavioral settings
     analysis_depth: comprehensive
     auto_fix_confidence_threshold: 0.85

     # Integration points
     integrations:
       metrics: [prometheus, datadog]
       logs: [elasticsearch, cloudwatch]
       communication: [slack, email]

     # Safety settings
     require_confirmation:
       production: true
       staging: false

     # Learning settings
     pattern_detection: true
     memory_retention_days: 90
   ```

4. **CI/CD Integration Examples**
   ```yaml
   # GitHub Actions
   - name: Run Analysis
     run: |
       claude /project:your-command analyze --output=json > results.json
       if [ $(jq '.critical_issues' results.json) -gt 0 ]; then
         claude /project:your-command fix --auto-approve
       fi
   ```

### 🚀 Command Quality Checklist

Before finalizing any command, verify:

#### Intelligence & Learning
- [ ] Recognizes patterns from past executions
- [ ] Provides insights humans would miss
- [ ] Explains reasoning behind recommendations
- [ ] Adapts based on environment/context

#### User Experience
- [ ] Works with zero configuration
- [ ] Provides meaningful progress indicators
- [ ] Offers escape hatches at every step
- [ ] Includes both beginner and expert modes

#### Safety & Reliability
- [ ] Every change has a rollback
- [ ] Dry-run mode available
- [ ] Confirms destructive operations
- [ ] Logs all actions taken

#### Integration & Extensibility
- [ ] Connects to common tools
- [ ] Outputs in multiple formats
- [ ] Provides hooks for customization
- [ ] Works in CI/CD pipelines

#### Real-World Value
- [ ] Saves >30 minutes per use
- [ ] Solves actual daily pain points
- [ ] Provides quantifiable improvements
- [ ] Builds institutional knowledge

### 🎨 Example: Generated Database Expert Command

```markdown
# /project:db-expert

Intelligent database optimization and troubleshooting across multiple database systems.

## Arguments
- `[action]` - Primary action:
  - `analyze` - Performance analysis and bottleneck detection
  - `optimize` - Query and schema optimization
  - `troubleshoot` - Debug specific issues
  - `migrate` - Safe schema migrations
  - `monitor` - Real-time performance monitoring

## Workflow Example
[Full implementation following k8s-expert patterns...]
```

### 📝 Generation Process

1. **Understand the Domain**
   - What tools do experts in this area use?
   - What are the common pain points?
   - What would a senior expert do?

2. **Design Multiple Modes**
   - Analysis mode for understanding
   - Fix mode for remediation
   - Monitor mode for prevention
   - Report mode for communication

3. **Include Real Commands**
   - Test every command example
   - Include error handling
   - Show actual output formats

4. **Build Intelligence**
   - Pattern recognition
   - Correlation across tools
   - Predictive recommendations

5. **Ensure Safety**
   - Rollback mechanisms
   - Confirmation prompts
   - Audit trails

### 🎯 The Ultimate Test

Ask yourself: "Would a senior engineer with 10 years experience be impressed by this command?"

If the answer is not an emphatic YES, keep improving.

## Configuration

`.claude/commandeering.yml`:

```yaml
commandeering:
  # Generation preferences
  default_style: expert
  default_complexity: advanced
  default_location: project

  # Quality standards
  minimum_features: 5
  require_visual_outputs: true
  require_real_examples: true

  # Patterns to always include
  required_patterns:
    - multi_mode_operation
    - intelligent_recommendations
    - safe_automation
    - visual_reporting
    - ci_cd_integration
```

Now, based on your request and following the k8s-expert level of sophistication, I'll generate your command...
