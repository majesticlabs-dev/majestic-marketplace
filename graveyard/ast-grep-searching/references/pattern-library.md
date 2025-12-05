# AST-Grep Pattern Library

Ready-to-use patterns for common refactoring tasks and code quality checks.

## Table of Contents

- [Ruby Patterns](#ruby-patterns)
- [JavaScript/TypeScript Patterns](#javascripttypescript-patterns)
- [Python Patterns](#python-patterns)
- [Migration Recipes](#migration-recipes)
- [Code Quality Rules](#code-quality-rules)


## Ruby Patterns

### ActiveRecord Patterns

```bash
# Find all Model.find calls
ast-grep run -l ruby -p 'User.find($ID)'

# Replace with find_by
ast-grep run -l ruby \
  -p 'User.find($ID)' \
  -r 'User.find_by(id: $ID)' -U

# Find where clauses with string interpolation (SQL injection risk)
ast-grep run -l ruby -p 'where("name = #{$VAR}")'

# Find all belongs_to without optional: true
ast-grep run -l ruby -p 'belongs_to :$ASSOC'
```

### Rails Controller Patterns

```bash
# Find before_action callbacks
ast-grep run -l ruby -p 'before_action :$METHOD'

# Find render calls
ast-grep run -l ruby -p 'render $OPTS'

# Find redirect_to
ast-grep run -l ruby -p 'redirect_to $PATH'

# Replace instance variable with local variable
ast-grep run -l ruby \
  -p '@$VAR = $VALUE' \
  -r '$VAR = $VALUE' -U
```

### Ruby Method Patterns

```bash
# Find all method definitions
ast-grep run -l ruby -p 'def $METHOD($$$ARGS); $$$BODY; end'

# Find private methods
ast-grep run -l ruby -p 'private\n\ndef $METHOD($$$ARGS); $$$BODY; end'

# Find attr_accessor usage
ast-grep run -l ruby -p 'attr_accessor :$ATTR'

# Convert attr_accessor to attr_reader
ast-grep run -l ruby \
  -p 'attr_accessor :$ATTR' \
  -r 'attr_reader :$ATTR' -U
```


## JavaScript/TypeScript Patterns

### Variable Declarations

```bash
# Find all var declarations
ast-grep run -l javascript -p 'var $VAR = $VALUE'

# Convert var to const
ast-grep run -l javascript \
  -p 'var $VAR = $VALUE' \
  -r 'const $VAR = $VALUE' -U

# Find let declarations
ast-grep run -l javascript -p 'let $VAR = $VALUE'

# Find uninitialized variables
ast-grep run -l javascript -p 'let $VAR;'
```

### Function Patterns

```bash
# Find traditional function declarations
ast-grep run -l javascript -p 'function $NAME($$$ARGS) { $$$BODY }'

# Convert to arrow function
ast-grep run -l javascript \
  -p 'const $NAME = function($$$ARGS) { $$$BODY }' \
  -r 'const $NAME = ($$$ARGS) => { $$$BODY }' -U

# Find async functions
ast-grep run -l javascript -p 'async function $NAME($$$ARGS) { $$$BODY }'

# Find arrow functions
ast-grep run -l javascript -p 'const $NAME = ($$$ARGS) => $BODY'
```

### Import/Export Patterns

```bash
# Find CommonJS require
ast-grep run -l javascript -p 'const $VAR = require("$MODULE")'

# Convert to ES6 import
ast-grep run -l javascript \
  -p 'const $VAR = require("$MODULE")' \
  -r 'import $VAR from "$MODULE"' -U

# Find named imports
ast-grep run -l javascript -p 'import { $IMPORTS } from "$MODULE"'

# Find default exports
ast-grep run -l javascript -p 'export default $VALUE'

# Update import paths
ast-grep run -l javascript \
  -p 'import $VAR from "old/path/$MODULE"' \
  -r 'import $VAR from "new/path/$MODULE"' -U
```

### React Patterns

```bash
# Find class components
ast-grep run -l typescript -p 'class $NAME extends Component { $$$BODY }'

# Find useState calls
ast-grep run -l typescript -p 'const [$STATE, $SETTER] = useState($INITIAL)'

# Find useEffect hooks
ast-grep run -l typescript -p 'useEffect(() => { $$$BODY }, [$$$DEPS])'

# Find console.log (should remove in production)
ast-grep run -l javascript -p 'console.log($$$ARGS)'

# Find inline styles (prefer CSS modules)
ast-grep run -l typescript -p '<$TAG style={{ $$$STYLES }} />'
```

### TypeScript Specific

```bash
# Find interface definitions
ast-grep run -l typescript -p 'interface $NAME { $$$FIELDS }'

# Find type aliases
ast-grep run -l typescript -p 'type $NAME = $DEF'

# Find any types (should avoid)
ast-grep run -l typescript -p 'const $VAR: any = $VALUE'

# Find as any casts (code smell)
ast-grep run -l typescript -p '$EXPR as any'
```


## Python Patterns

### Import Patterns

```bash
# Find all imports
ast-grep run -l python -p 'import $MODULE'

# Find from imports
ast-grep run -l python -p 'from $MODULE import $ITEMS'

# Update import paths
ast-grep run -l python \
  -p 'from old.module import $ITEMS' \
  -r 'from new.module import $ITEMS' -U
```

### Function and Class Patterns

```bash
# Find function definitions
ast-grep run -l python -p 'def $FUNC($$$ARGS):'

# Find class definitions
ast-grep run -l python -p 'class $CLASS:'

# Find class methods
ast-grep run -l python -p 'def $METHOD(self, $$$ARGS):'

# Find decorators
ast-grep run -l python -p '@$DECORATOR\ndef $FUNC($$$ARGS):'
```

### Django Patterns

```bash
# Find all Model definitions
ast-grep run -l python -p 'class $MODEL(models.Model):'

# Find ForeignKey fields
ast-grep run -l python -p '$FIELD = models.ForeignKey($$$ARGS)'

# Find all views
ast-grep run -l python -p 'def $VIEW(request, $$$ARGS):'
```


## Migration Recipes

### API Version Migration (Ruby)

```bash
# Step 1: Find old API calls
ast-grep run -l ruby -p 'OldAPI.call($METHOD, $$$ARGS)'

# Step 2: Replace with new API
ast-grep run -l ruby \
  -p 'OldAPI.call($METHOD, $$$ARGS)' \
  -r 'NewAPI.execute(method: $METHOD, params: { $$$ARGS })' \
  -U
```

### Module Import Migration (JavaScript)

```bash
# Migrate from lodash to lodash-es
ast-grep run -l javascript \
  -p 'import _ from "lodash"' \
  -r 'import _ from "lodash-es"' \
  -U

# Migrate named imports
ast-grep run -l javascript \
  -p 'import { $FUNCS } from "lodash"' \
  -r 'import { $FUNCS } from "lodash-es"' \
  -U
```

### React Class to Hooks Migration

```bash
# Step 1: Find class components
ast-grep run -l typescript -p 'class $NAME extends Component { $$$BODY }'

# Step 2: Convert state initialization
ast-grep run -l typescript \
  -p 'this.state = { $$$STATE }' \
  -r 'const [state, setState] = useState({ $$$STATE })' \
  -U

# Step 3: Convert this.state references
ast-grep run -l typescript \
  -p 'this.state.$PROP' \
  -r 'state.$PROP' \
  -U

# Step 4: Convert this.setState calls
ast-grep run -l typescript \
  -p 'this.setState({ $$$UPDATES })' \
  -r 'setState({ ...state, $$$UPDATES })' \
  -U
```

### Deprecation Removal

```bash
# Find deprecated jQuery methods
ast-grep run -l javascript -p '$.ajax($$$ARGS)'

# Replace with fetch
ast-grep run -l javascript \
  -p '$.ajax({ url: $URL, method: $METHOD })' \
  -r 'fetch($URL, { method: $METHOD })' \
  -U
```


## Code Quality Rules

### No Console in Production (JavaScript)

```yaml
# .ast-grep/rules/no-console.yml
id: no-console-log
message: Remove console.log before production
severity: warning
language: javascript
rule:
  pattern: console.log($$$ARGS)
```

### Require Error Handling (TypeScript)

```yaml
# .ast-grep/rules/require-try-catch.yml
id: async-without-error-handling
message: Async function should have error handling
severity: warning
language: typescript
rule:
  all:
    - pattern: |
        async function $NAME($$$ARGS) {
          $$$BODY
        }
    - not:
        inside:
          pattern: |
            try {
              $$$TRY
            } catch ($ERR) {
              $$$CATCH
            }
```

### SQL Injection Prevention (Ruby)

```yaml
# .ast-grep/rules/sql-injection.yml
id: sql-injection-risk
message: Potential SQL injection via string interpolation
severity: error
language: ruby
rule:
  pattern: where("$QUERY #{$VAR}")
fix: where($QUERY, $VAR)
```

### Hardcoded Secrets (All Languages)

```yaml
# .ast-grep/rules/hardcoded-secrets.yml
id: hardcoded-api-key
message: Possible hardcoded API key or secret
severity: error
language: javascript
rule:
  pattern: const $KEY = "$VALUE"
  constraints:
    KEY:
      regex: "(?i)(api[_-]?key|secret|token|password)"
    VALUE:
      regex: "^[A-Za-z0-9+/=]{20,}$"
```

### Large Functions (JavaScript)

```yaml
# .ast-grep/rules/large-function.yml
id: function-too-large
message: Function exceeds recommended size
severity: info
language: javascript
rule:
  pattern: |
    function $NAME($$$ARGS) {
      $$$BODY
    }
  constraints:
    BODY:
      regex: "(?s).{1000,}"  # > 1000 characters
```


## Quick Refactoring Commands

### Rename API Across Codebase

```bash
# Ruby: Rename method
ast-grep run -l ruby \
  -p 'old_method($$$ARGS)' \
  -r 'new_method($$$ARGS)' \
  -U

# JavaScript: Rename function
ast-grep run -l javascript \
  -p 'oldFunction($$$ARGS)' \
  -r 'newFunction($$$ARGS)' \
  -U
```

### Update Configuration Format

```bash
# Change object property names
ast-grep run -l javascript \
  -p '{ oldKey: $VALUE }' \
  -r '{ newKey: $VALUE }' \
  -U

# Update nested properties
ast-grep run -l typescript \
  -p 'config.old.path' \
  -r 'config.new.path' \
  -U
```

### Remove Deprecated Code

```bash
# Find and remove deprecated decorators
ast-grep run -l python \
  -p '@deprecated\ndef $FUNC($$$ARGS):' \
  -r 'def $FUNC($$$ARGS):' \
  -U

# Remove deprecated imports
ast-grep run -l javascript \
  -p 'import { deprecated$NAME } from "$MODULE"' \
  -r 'import { $NAME } from "$MODULE"' \
  -U
```


## Language-Specific Tips

### Ruby

- Use `-l ruby` for .rb files and Gemfile
- Match both `def` and `private def` separately
- Remember Ruby's flexible syntax (parentheses optional)

### JavaScript/TypeScript

- Use `-l js` for .js, .jsx, .mjs
- Use `-l ts` for .ts, .tsx
- Pattern for optional semicolons

### Python

- Use `-l python` for .py files
- Mind indentation in patterns
- Decorators are separate nodes

### Go

- Use `-l go` for .go files
- Match exported vs unexported names differently
- Consider pointer vs value receivers


**Pattern Library Status**: Complete - Ready-to-use refactoring patterns ✅
**Use with**: Main SKILL.md and ADVANCED_RULES.md for complete coverage
