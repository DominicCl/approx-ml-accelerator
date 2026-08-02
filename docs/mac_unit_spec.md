# MAC Unit Design Spec — v1

Decided in Phase 1, Step 2 (design decision session).

## Purpose

This is the core arithmetic unit of our approximate-computing ML accelerator.
Its job: multiply a weight and an activation, add the result into a running
accumulator — but with hardware support for deliberately skipping
near-zero-value work to save energy, at a quantified accuracy cost.

## Precision modes

| Parameter          | Mode A (baseline) | Mode B (reduced) |
|---------------------|--------------------|--------------------|
| Weight width         | 8-bit               | 4-bit               |
| Activation width      | 8-bit               | 8-bit               |
| Accumulator width      | 32-bit              | 16-bit              |

Rationale: weights tolerate quantization better than activations, since
weights are fixed after training (no per-input dynamic range to preserve),
while activations vary per input and carry more information. This is a
standard finding in ML quantization literature, so we cut weight precision
more aggressively than activation precision in Mode B.

## Approximation mechanisms

### 1. Near-zero weight skip
- A comparator checks `abs(weight) < threshold`.
- `threshold` is a **runtime-configurable register** (not hardwired), so we
  can sweep it during accuracy analysis (Phase 5) rather than being locked
  to one guess at design time.
- When triggered: a multiplexer bypasses the multiplier, feeding a zero
  contribution into the accumulator, AND the multiplier is clock-gated for
  that cycle (no switching activity = the actual energy saving, not just a
  correct-but-wasteful zero result).

### 2. Near-zero activation skip
- Exact-zero detection on the activation input (simpler than a threshold
  compare, since ReLU-based networks produce exact zero activations very
  commonly).
- Same bypass + clock-gate behavior as weight skip.

### 3. Clock gating granularity
- Per-MAC-unit, per-cycle. Each MAC unit independently decides every cycle
  whether it has real work to do.
- Finest-grained option; feasible given our array size (4x4 or 8x8), and
  gives the most realistic (least optimistic) energy numbers.

## Open questions / future sweep parameters (Phase 5)
- Exact value(s) of the weight-skip threshold register to test
- Whether Mode A and Mode B should be selectable per-layer (mixed
  precision) — flagged as a possible Phase 5 extension, not built into the
  RTL from day one.
