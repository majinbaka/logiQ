---
name: flutter-workflow
description: Use when implementing or fixing Flutter features, widgets, screens, navigation, forms, or data flow; this skill provides a repeatable delivery workflow from context scan to verification.
---

# Flutter Workflow

## When To Use

Use this skill when the request changes Flutter behavior in `lib/`, `test/`, `pubspec.yaml`, navigation, state flow, or feature wiring.

## Workflow

1. Establish scope.
   - Identify changed feature and impacted layers.
   - Confirm whether generated files are involved.

2. Read the minimum required context.
   - Start from entry points (`main.dart`, feature route/view, related tests).
   - Expand only to directly connected classes.

3. Choose the smallest viable patch.
   - Prefer targeted edits over refactors.
   - Keep public contracts stable unless the request requires change.

4. Implement by layer.
   - UI/presentation: widget layout, user interactions.
   - State/view-model: user intent -> state transition.
   - Data/domain: repository/service updates when required.

5. Verify with proportional checks.
   - Run static checks first, then targeted tests.
   - Escalate to wider checks only when impact is broad.

6. Report with evidence.
   - Summarize changed files and behavior impact.
   - List commands run and unresolved risks.

## Coordination

- Use `flutter-architecture-guard` when introducing dependencies, new layers, or state-management changes.
- Use `flutter-quality-gates` before marking work complete.
- Use [workflow-checklist.md](references/workflow-checklist.md) for a compact execution checklist.
