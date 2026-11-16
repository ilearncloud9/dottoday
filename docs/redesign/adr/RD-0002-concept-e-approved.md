# RD-0002 · Concept E is the approved design for production

Status: **Accepted** by the owner 2026-11-15 (ED-353) · Scope: the redesign, branch `redesign/design-lab` and the build that follows · Numbering: `RD-` keeps redesign ADRs apart from `docs/adr/`. RD-0001 is not rewritten; this record builds on it.

## Context

RD-0001 opened three concepts and set one identity with native presentations per platform. Concept E ("Refined Focus", the owner's modified A) became the leading candidate on 2026-11-04. It was reviewed group by group:
- Groups 1 to 4: ED-065 to ED-196.
- The cleanup batch: ED-197 to ED-221.
- Round 2 with the tablet checklist: ED-249, R2-1 to R2-42, ED-264 to ED-349.

ED-238 made the overall approval a release gate after Round 2.

## Decision

1. Concept E is approved for production implementation as recorded in `docs/redesign/E_DESIGN_DECISIONS.md` (ED-001 to ED-353). The build sources are listed in `E_IMPLEMENTATION_HANDOFF.md` § "Build sources".
2. Concept E replaces Concept A (`docs/10-ui-concept-a.md`, ADR-0007) as the design source for the redesign build. Those stay as history; existing ADRs are not rewritten.
3. RD-0001 still governs presentation: one identity, native presentation per platform, layout by width class.

## Consequences

- Building goes through `docs/09-implementation-plan.md` tasks (Prompt F), each with its definition of done (CLAUDE.md §5).
- These still gate the parts they cover:
  - the CR-160 release blocker and its account screens (to draw after PR #75);
  - the Q9 isolated test stack (ED-352) before integration tests;
  - device and accessibility tests (handoff);
  - CLAUDE.md §10 must-ask items, including schema changes, the hosted Supabase project (Q11, Q13), new dependencies and new native targets.
- CLAUDE.md §11 still names `DESIGN_PRINCIPLES.md` and RD-0001 for UI on this branch. Naming Concept E there is a rulebook change for the owner to approve.
