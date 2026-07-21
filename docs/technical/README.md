# MoodX Technical Documentation

- **System:** MoodX Mixer for macOS
- **Version documented:** 0.4.0 (build 6)
- **Last reviewed:** 2026-07-19
- **Status:** Implemented local prototype; Teams end-to-end validation pending

This directory is the canonical technical description of the current native
MoodX mixer. Product intent belongs under [`../product/`](../product/), accepted
decisions belong in [`../ADR.md`](../ADR.md), and operator setup belongs in the
[`../../macos/MoodXMixer/README.md`](../../macos/MoodXMixer/README.md).

## Document map

1. [System context](SYSTEM_CONTEXT.md) — people, systems, trust boundaries, and
   external dependencies.
2. [System overview](SYSTEM_OVERVIEW.md) — runtime behavior, major flows, and
   operational lifecycle.
3. [Architecture](ARCHITECTURE.md) — components, audio graph, concurrency,
   persistence, failure handling, and deployment.
4. [Data flow](DATA_FLOW.md) — mixer audio, local STT, control, bookmark, state,
   retention, trust-boundary, and error flows.
5. [Requirements](REQUIREMENTS.md) — traceable functional and non-functional
   requirements, constraints, exclusions, and verification state.
6. [Beta distribution](BETA_DISTRIBUTION.md) — Developer ID signing,
   notarization, packaging, tester onboarding, and TestFlight trade-offs.

## Documentation conventions

- **Implemented** means the behavior exists in the current source.
- **Verified** means the named check has been performed successfully.
- **Pending** means the behavior exists but still requires the stated test.
- **Planned** means the behavior is not implemented.
- Unknown targets and thresholds are written as `TBD`.
- Mermaid diagrams are authoritative code-native views. AI-generated deck
  illustrations are conceptual and are not architecture sources.

## Source-of-truth hierarchy

When records disagree, reconcile them in this order:

1. accepted decisions in `docs/ADR.md`;
2. current executable source and tests under `macos/MoodXMixer/`;
3. this technical documentation;
4. operator and product documentation;
5. conceptual presentation imagery.
