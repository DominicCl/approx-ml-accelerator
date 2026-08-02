# mlchip — Approximate-Computing ML Accelerator

An RTL (Verilog) chip design project: an ML accelerator's multiply-
accumulate (MAC) unit that deliberately trades numerical precision for
energy savings, using techniques informed by real neural network
behavior:

- **Near-zero weight skipping** — trained neural networks end up with
  many near-zero weights; skipping the multiply-accumulate for these
  saves energy at a small, quantifiable accuracy cost.
- **Near-zero activation skipping** — ReLU-based networks produce many
  exact-zero activations; skipping these too compounds the savings.
- **True input-gating (pipelined design)** — rather than computing a
  result and discarding it, the design gates the multiplier's own
  *inputs*, so skipped cycles produce no new switching activity at the
  multiplier itself, not just at the accumulator.

## Project status

Currently in Phase 2 (core RTL design), building toward:
- Phase 3: a small systolic array of these MAC units
- Phase 4: synthesis (Yosys) for real gate-count/area numbers
- Phase 5: C++ accuracy analysis against a real trained ML model
- Phase 6: hardware validation on real ESP32 and STM32 boards
- Phase 7: final report
- Phase 8 (optional stretch): physical layout via OpenROAD + KLayout

See `docs/mac_unit_spec.md` for the detailed design spec and rationale.

## Repo layout

- `rtl/` — the actual hardware design files (Verilog modules)
- `tb/` — testbenches (simulation-only test harnesses, not part of the chip)
- `sim/` — compiled simulation outputs (gitignored, regenerated on demand)
- `docs/` — design decision records and notes

## Toolchain

Requires Icarus Verilog (`iverilog`, `vvp`) for simulation, and Yosys for
synthesis. On Debian/Ubuntu:

```
sudo apt-get install iverilog yosys gtkwave
```

## Running a testbench

```
iverilog -o sim/<name>.out rtl/<module>.v tb/<module>_tb.v
vvp sim/<name>.out
```
