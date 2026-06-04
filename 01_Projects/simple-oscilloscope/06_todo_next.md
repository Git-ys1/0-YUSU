# Todo Next

## Next Actions

- [ ] If hardware input measurement becomes real, add/verify ADC acquisition path and analog front-end documentation; current firmware primarily demonstrates generated waveform/PWM/sample stream behavior.
- [ ] Add explicit user-facing "connected vs running" visual affordance if blank-screen confusion recurs.
- [ ] Consider a signed installer and crash reporting only after the hand-in scope is stable.
- [ ] Add more realistic ADC/front-end safety tests before any high-voltage or AC measurement claim.

## Evidence Gaps

- [ ] Early v0.1.0/v0.2.1 user intent is inferred mostly from git history and current docs; no separate product spec was found for the earliest phase.
- [ ] Release asset checks are recorded in conversation/session evidence, not a committed CI artifact for installer smoke tests.

## Needs User Decision

- [ ] Whether the next milestone should become real ADC measurement, dual-channel UI, FFT/spectrum, protocol decoder, or analog front-end design.

## Later

- [ ] CH2 and multi-trace architecture.
- [ ] FFT / Spectrum Analyzer.
- [ ] Logic Analyzer.
- [ ] USB CDC or faster transport.
- [ ] More capable MCU if 20 kSa/s is not enough.
