# Rails Engine Migrations

Keep migrations in the engine instead of copying to host applications.

## Implementation

In `lib/your_engine/engine.rb`:

```ruby
module YourEngine
  class Engine < ::Rails::Engine
    isolate_namespace YourEngine

    initializer :append_migrations do |app|
      # Skip if running within the engine itself (e.g., dummy test app)
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
```

## Benefits

- **Colocation**: Migrations live with the models they support
- **No copying**: Host app doesn't need `rails your_engine:install:migrations`
- **Automatic**: Migrations run with standard `rails db:migrate`

## The Guard Clause

```ruby
unless app.root.to_s.match?(root.to_s)
```

Prevents migrations from being added twice when running tests in the engine's dummy app, where the app root IS the engine root.

## Anti-Patterns

| Avoid | Why |
|-------|-----|
| Manipulating `ActiveRecord::Migrator.migrations_paths` directly | Rails handles this when you add to `app.config.paths["db/migrate"]` |
| Mixing approaches (initializer + `install:migrations` rake task) | Causes duplicate migration errors |
| Relative path comparisons | Use expanded/absolute paths to avoid duplicates from `db/migrate` vs `/full/path/db/migrate` |
