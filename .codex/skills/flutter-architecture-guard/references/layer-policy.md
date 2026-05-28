# Layer Policy for Flutter Projects

## Allowed Dependency Direction

- `presentation` -> `state` -> `domain/data`
- `features/*` may depend on `core/*`
- `core/*` must not depend on feature modules

## Common Violations

- Widget directly calling remote client or local box
- View model importing concrete infra class instead of contract
- Feature A importing Feature B internals for convenience

## Preferred Fixes

- Move shared logic into `core/`
- Depend on interface/contract, inject implementation
- Isolate side effects into repository/service layer

## Schema and Migration

If persisted model changes:

1. Update model and adapters
2. Update repository contract + implementation
3. Add migration/version handling
4. Add focused tests for backward compatibility
