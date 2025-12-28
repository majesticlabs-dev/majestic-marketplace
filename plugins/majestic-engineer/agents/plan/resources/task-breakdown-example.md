# Task Breakdown Example

Given a plan for "Add user authentication":

```markdown
---

## Implementation Tasks

### Parallelization Matrix

| Group | Tasks | Blocked By |
|-------|-------|------------|
| A | T1: Create users table migration | - |
| B | T2: Add User model, T3: Add password validations | A |
| C | T4: Create sessions controller, T5: Add login route | B |
| D | T6: Add login form view, T7: Add current_user helper | C |
| E | T8: Write User model specs, T9: Write auth request specs | D |

### Task Details

#### Group A (Start Immediately)

- [ ] **T1**: Create users table migration
  - Priority: p1
  - Story Points: 2
  - Depends on: none
  - Files: db/migrate/xxx_create_users.rb
  - Acceptance: Migration runs, table exists

#### Group B (After Group A)

- [ ] **T2**: Add User model with has_secure_password
  - Priority: p1
  - Story Points: 2
  - Depends on: T1
  - Files: app/models/user.rb
  - Acceptance: User.create works with password

- [ ] **T3**: Add email/password validations to User
  - Priority: p1
  - Story Points: 2
  - Depends on: T1
  - Files: app/models/user.rb
  - Acceptance: Validations reject invalid data

#### Group C (After Group B)

- [ ] **T4**: Create sessions controller with create/destroy
  - Priority: p1
  - Story Points: 3
  - Depends on: T2, T3
  - Files: app/controllers/sessions_controller.rb
  - Acceptance: Login/logout actions work

- [ ] **T5**: Add login/logout routes
  - Priority: p1
  - Story Points: 1
  - Depends on: T2
  - Files: config/routes.rb
  - Acceptance: Routes resolve correctly

#### Group D (After Group C)

- [ ] **T6**: Add login form view
  - Priority: p2
  - Story Points: 2
  - Depends on: T4, T5
  - Files: app/views/sessions/new.html.erb
  - Acceptance: Form renders, submits correctly

- [ ] **T7**: Add current_user helper
  - Priority: p2
  - Story Points: 2
  - Depends on: T4
  - Files: app/controllers/application_controller.rb
  - Acceptance: current_user available in views

#### Group E (After Group D)

- [ ] **T8**: Write User model specs
  - Priority: p2
  - Story Points: 2
  - Depends on: T2, T3
  - Files: spec/models/user_spec.rb
  - Acceptance: All specs pass

- [ ] **T9**: Write authentication request specs
  - Priority: p2
  - Story Points: 3
  - Depends on: T6, T7
  - Files: spec/requests/authentication_spec.rb
  - Acceptance: Login/logout flows tested

### Total: 19 Story Points (9 tasks)
```
