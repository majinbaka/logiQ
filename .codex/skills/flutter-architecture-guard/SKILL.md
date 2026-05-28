---
name: flutter-architecture-guard
description: Use when a Flutter change may alter architecture boundaries, state management, or dependency direction; this skill prevents cross-layer coupling and fragile design shortcuts.
---

# Flutter Architecture Guard

## When To Use

Use this skill for:

- New feature/module scaffolding
- State-management redesign
- Repository/service contract changes
- Navigation flows spanning multiple features
- Any change that introduces new dependencies

## Guardrails

1. Keep layers explicit.
   - Presentation handles rendering and user interaction.
   - State layer handles orchestration and transitions.
   - Data/domain layer handles persistence, API, mapping.

2. Avoid forbidden coupling.
   - No direct API/storage calls from widget `build()` paths.
   - No feature-to-feature imports when a shared core contract is more appropriate.
   - No circular dependencies.

3. Prefer contract-first changes.
   - Define or update repository/service interface before implementation.
   - Add migration steps when persisted schema changes.

4. Keep state predictable.
   - One source of truth per screen flow.
   - Avoid duplicated mutable state across widgets and view-models.

## Practical Review Pass

Before finalizing:

- Check imports for layer violations.
- Check where side effects are executed.
- Check if any new dependency could live in `core/` instead of feature modules.
- Run through [layer-policy.md](references/layer-policy.md).
