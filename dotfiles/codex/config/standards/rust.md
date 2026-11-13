# Rust Development Standards

## Dependencies and features

- **Keep dependency features intentional.** Disable default features when the
  required feature set is understood and doing so provides a meaningful benefit.

- **Prefer explicit feature selection when appropriate.** For example:

  ```toml
  syn = { version = "...", default-features = false, features = ["parsing"] }
  ```

- **Separate test-only capabilities.** Prefer dev-dependencies for dependencies
  used exclusively by tests.

- **Avoid unnecessary dependency expansion.** Do not increase the production
  dependency or feature surface merely for test convenience without a clear
  benefit.

- **Consider maintenance costs.** Prefer existing dependencies or
  standard-library facilities over adding crates for trivial functionality.
