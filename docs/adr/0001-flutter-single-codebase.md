# ADR-0001: Flutter single codebase for iOS, Android, macOS, Web

**Status**: accepted · **Date**: 2026-10-20

## Context
The original app's Android and web versions lag iOS (R-13). We need four targets from a small team with a drag-heavy custom timeline UI.

## Decision
One Flutter codebase. Custom-drawn timeline (CustomScrollView + slivers, custom gesture recognisers). Platform-specific affordances through adaptive widgets and small Swift/Kotlin plugins for widgets and menu bar.

## Consequences
+ Parity by construction; one test suite; strong canvas performance for the timeline.
− Web at-rest encryption weaker (ADR-0003); some native polish (Live Activities, watch) requires Swift later.
