---
module: API Gateway
date: 2025-12-01
problem_type: security_issue
component: auth
symptoms:
  - "API keys visible in request logs"
  - "Keys exposed in error stack traces"
root_cause: missing_validation
resolution_type: code_fix
severity: critical
tags: [api-key, secrets, logging, security]

# Discovery fields
lesson_type: antipattern
workflow_phase: [review, planning]
tech_stack: [generic]
impact: blocks_work
keywords: [api_key, secret, token, credentials, logging, sensitive, filter_parameters]
---

# Troubleshooting: API Keys Exposed in Application Logs

## Problem

API keys were being logged in plain text in both request logs and error stack traces, creating a security vulnerability and compliance issue.

## Environment

- Module: API Gateway
- Affected Component: `config/application.rb`, logging middleware
- Date: 2025-12-01

## Symptoms

- API keys visible in request logs
- Keys exposed in error stack traces
- Security audit flagged plaintext secrets in log files
- Potential credential exposure in log aggregation services

## What Didn't Work

**Attempted Solution 1:** Grep and delete sensitive logs
- **Why it failed:** Reactive, not preventive. Keys were already exposed.

## Solution

Filter sensitive parameters at the framework level:

**Rails:**

```ruby
# config/application.rb
config.filter_parameters += [
  :password, :password_confirmation,
  :api_key, :api_secret, :access_token,
  :authorization, :bearer, :token,
  :secret, :credentials
]
```

**Node.js (Express + Morgan):**

```javascript
const sensitiveFields = ['api_key', 'authorization', 'token', 'secret'];

morgan.token('filtered-body', (req) => {
  const body = { ...req.body };
  sensitiveFields.forEach(field => {
    if (body[field]) body[field] = '[FILTERED]';
  });
  return JSON.stringify(body);
});
```

**Python (Django):**

```python
# settings.py
import re
SENSITIVE_VARIABLES_RE = re.compile(
    r'api[_-]?key|secret|token|password|authorization',
    re.IGNORECASE
)

# In logging config
'filters': {
    'sensitive_data': {
        '()': 'django.utils.log.SensitiveDataFilter',
    }
}
```

## Why This Works

1. **Root cause:** Default logging configurations capture all request parameters without filtering sensitive data.

2. **Solution mechanism:** Framework-level parameter filtering replaces sensitive values with `[FILTERED]` before they reach any logging layer.

3. **Defense in depth:** Even if a developer accidentally logs a request, sensitive fields are already sanitized.

## Prevention

- Add parameter filtering in initial project setup (not as afterthought)
- Include common sensitive field names by default
- Add regex patterns for dynamic secret names (e.g., `*_key`, `*_secret`)
- Configure log aggregation services to redact patterns
- Review logs in CI for sensitive data patterns

## Related Issues

No related issues documented yet.

## Checklist for Code Review

When reviewing auth-related code, verify:

- [ ] No API keys in plain text logs
- [ ] `filter_parameters` includes all secret field names
- [ ] Error handlers don't expose full request context
- [ ] Test fixtures use fake/rotated credentials
- [ ] Environment variables for secrets, not hardcoded
