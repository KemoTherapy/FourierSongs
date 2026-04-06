# Fourier Analysis of Musical Keys

**"Spectral Properties of a Simple Melody Across All 12 Major Keys"**

A computational study examining why different musical keys feel, sound, and behave differently — through the lens of Fourier analysis.

---

## Overview

This project synthesizes *Twinkle Twinkle Little Star* in all 12 chromatic major keys and applies FFT and STFT analysis to quantify how key selection affects the spectral properties of a melody. The analysis provides an objective, measurable basis for the centuries-old tradition of "key characteristics" (*Charakteristik der Tonarten*) — the idea that different keys carry different emotional or tonal qualities.

**Core question:** When you transpose a melody to a different key, what actually changes in the sound, and can those changes explain why musicians and theorists have always treated keys as distinct?

**Short answer:** Yes. Higher keys are measurably brighter (higher spectral centroid), have more spread-out harmonic content (wider bandwidth), and exhibit greater beating against just-intonation intervals — all of which are perceptible to human listeners.

---

## Repository Structure

```
.
├── twinkle_fourier_analysis.m   # Main MATLAB script (run this)
├── results/                     # Auto-generated output folder
│   ├── Fig1_Waveforms.png
│   ├── Fig2_FFT_AllKeys.png
│   ├── Fig3_FFT_4Keys.png
│   ├── Fig4_Spectrogram.png
│   ├── Fig5_SpectralFeatures.png
│   ├── Fig6_HarmonicPartials.png
│   ├── Fig7_RootNoteFFT.png
│   ├── Fig8_Beating.png
│   └── spectral_data.mat
└── README.md
```

---

## Requirements

- **MATLAB** R2019b or later
- **Signal Processing Toolbox** (required for `spectrogram()` and `hann()`)

No external dependencies or additional toolboxes are needed.

---

## How to Run

1. Clone or download this repository
2. Open MATLAB and navigate to the project folder
3. Run:
```matlab
twinkle_fourier_analysis
```

The script will:
- Synthesize the melody in all 12 keys (~10 seconds)
- Compute FFT spectra and STFT spectrograms
- Extract spectral centroid, bandwidth, and rolloff
- Analyze harmonic partials and equal-temperament beating
- Save 8 publication-quality figures to `results/`
- Save all numerical data to `results/spectral_data.mat`
- Print a summary table to the command window

Runtime: approximately 2–3 minutes on a standard desktop.

---

## What the Code Does

### Signal Synthesis
Each note is synthesized using **additive synthesis** with 5 harmonic partials at amplitudes {1.0, 0.5, 0.25, 0.125, 0.0625}, approximating a piano-like timbre. An ADSR envelope (10 ms attack, 50 ms decay, 0.75 sustain, 80 ms release) is applied to each note. Equal temperament tuning is used with A4 = 440 Hz.

### FFT Analysis
The complete 42-note signal for each key is transformed using MATLAB's `fft()`. The single-sided magnitude spectrum is computed and converted to dBFS. Three spectral features are extracted:
- **Spectral centroid** — power-weighted mean frequency (correlates with perceived brightness)
- **Spectral bandwidth** — power-weighted frequency spread
- **85% spectral rolloff** — frequency below which 85% of spectral power is concentrated

### STFT Spectrogram
A Short-Time Fourier Transform is computed with a 50 ms Hann window, 10 ms hop, and 4096-point FFT, giving ~10.8 Hz frequency resolution and 10 ms temporal resolution.

### Harmonic Partial Analysis
For each key, the amplitude of the first 8 harmonic partials is measured from the FFT of the isolated root note, then normalized to the fundamental for cross-key comparison.

### Beating Analysis
Equal-temperament beating frequencies are computed for the major third and perfect fifth relative to their just-intonation ratios (5:4 and 3:2 respectively):
```
Δf = |f_interval - ratio × f_root|
```

---

## Key Results

| Feature | C Major | B Major | Change |
|---|---|---|---|
| Root frequency (f₀) | 261.6 Hz | 493.9 Hz | +89% |
| Spectral centroid | 473 Hz | 868 Hz | +83% |
| Spectral bandwidth | 231 Hz | 432 Hz | +87% |
| 85% Rolloff | 680 Hz | 1,301 Hz | +91% |
| Major 3rd beating | 2,590 mHz | 4,904 mHz | +89% |
| Perfect 5th beating | 446 mHz | 841 mHz | +89% |

All spectral features scale near-linearly with root frequency (R² > 0.999), confirming that equal-temperament transposition is a frequency-scaling operation. The major-third beating values (2.6–4.9 Hz) fall within the perceptually salient roughness range identified by Plomp & Levelt (1965).

---

## Figures

| Figure | Description |
|---|---|
| Fig 1 | Synthesized waveforms for 4 selected keys |
| Fig 2 | Overlaid FFT spectra for all 12 keys (0–4 kHz) |
| Fig 3 | FFT spectra for 4 keys with f₀ markers |
| Fig 4 | STFT spectrograms for 4 keys (0–5 kHz) |
| Fig 5 | Spectral centroid, bandwidth, rolloff across all 12 keys |
| Fig 6 | Harmonic partial heatmap (normalized amplitude) |
| Fig 7 | Root-note FFT showing harmonic series for all 12 keys |
| Fig 8 | Equal-temperament beating vs. just intonation for all 12 keys |

---

## Background

The idea that different musical keys have different characters is ancient. Schubart (1806) called C major "innocent," F♯ major "passionate," and B major "wild." Mattheson (1713) catalogued expressive qualities for every key. For centuries this was attributed to either:

1. **Unequal temperament** — historical tuning systems made some keys purer and others rougher
2. **Instrument construction** — piano and organ pipes have different physical properties per key
3. **Absolute pitch perception** — trained listeners literally hear that one key is higher than another

This project examines a fourth, overlooked explanation: **even in perfect equal temperament with a neutral synthetic timbre**, different keys produce objectively different spectral distributions. Higher keys are brighter, have more high-frequency harmonic content, and produce more rapid beating against just intonation. These are perceptible differences with no instrument-specific cause — they arise purely from the physics of pitch.

---

## Citation

If you use this code or data in your own work, please cite:

```
[Kamaleldin Kamaleldin]. (2026). Spectral Properties of a Simple Melody Across All 12 Major Keys.
GitHub. https://github.com/[KemoTherapy]/[FourierSongs]
```

---

## License

MIT License. See `LICENSE` for details.

---

## References

Selected key references:
- Plomp, R. & Levelt, W. J. M. (1965). Tonal consonance and critical bandwidth. *JASA*, 38(4), 548–560.
- Helmholtz, H. L. F. (1885). *On the Sensations of Tone*. Longmans, Green.
- Schubart, C. F. D. (1806). *Ideen zu einer Ästhetik der Tonkunst*. J. V. Degen.
- Sethares, W. A. (2005). *Tuning, Timbre, Spectrum, Scale* (2nd ed.). Springer.
- Benson, D. J. (2007). *Music: A Mathematical Offering*. Cambridge University Press.

Full references are provided in the accompanying manuscript.
