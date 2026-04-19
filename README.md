# Fourier-Key-Analysis

**"Spectral Properties of a Simple Melody Across All 12 Major Keys"**

Computational spectral analysis of *Twinkle Twinkle Little Star* synthesized in all 12 chromatic major keys via FFT and STFT.

Disclaimer: I did this for fun lol do not take this seriously

---

## Overview

This project synthesizes *Twinkle Twinkle Little Star* in all 12 chromatic major keys and applies FFT and STFT analysis to quantify how key selection affects the spectral properties of a melody. The core question is what physically changes in a signal when a melody is transposed — specifically whether spectral centroid, bandwidth, rolloff, and equal-temperament beating vary predictably across keys.

---

## Repository Structure

```
.
├── twinkle_fourier_analysis.m   # Main MATLAB script (run this)
├── results/                     # Auto-generated on first run
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

- MATLAB R2019b or later
- Signal Processing Toolbox (`spectrogram`, `hann`)

---

## Usage

```matlab
twinkle_fourier_analysis
```

Writes 8 figures and `spectral_data.mat` to `results/`. Prints a feature summary table to the command window. Runtime is approximately 2–3 minutes.

---

## What the Code Does

### Signal synthesis

Each note is synthesized as a sum of 5 harmonic partials with geometrically decaying amplitudes:

```
s(t) = sum_{h=1}^{5} (1/2^{h-1}) * sin(2*pi*h*f0*t)
```

An ADSR envelope is applied (10 ms attack, 50 ms decay to 0.75 sustain, 80 ms release). Equal temperament throughout, A4 = 440 Hz (ISO 16:1975). The script defines three local functions — `adsr()`, `key_rgb()`, and `db()` — used internally and not exported.

### FFT analysis

The full 42-note signal for each key is transformed with `fft()`. Single-sided magnitude spectrum computed as `(2/N)*abs(fft(x))`, converted to dBFS. Three spectral features extracted per key:

- **Spectral centroid** — power-weighted mean frequency
- **Spectral bandwidth** — power-weighted standard deviation around the centroid
- **85% rolloff** — frequency below which 85% of total spectral power is concentrated

### STFT spectrogram

50 ms Hann window, 10 ms hop, 4096-point FFT (~10.8 Hz frequency resolution, 10 ms temporal resolution).

### Harmonic partial analysis

Root note isolated (one beat duration) per key. Amplitudes of partials 1–8 extracted by peak-finding within ±5 Hz of each expected frequency `h*f0`, normalized to the fundamental. Stored in `par_norm`.

### Beating analysis

Equal-temperament deviation from just intonation for the major third (5:4) and perfect fifth (3:2):

```
beat_f = |f_ET_interval - ratio * f_root|   [converted to mHz]
```

---

## Key Results

|  | C | B | Δ |
|---|---|---|---|
| f₀ (Hz) | 261.6 | 493.9 | +89% |
| Centroid (Hz) | 473 | 868 | +84% |
| Bandwidth (Hz) | 231 | 432 | +87% |
| 85% Rolloff (Hz) | 680 | 1301 | +91% |
| Major-3rd beat (mHz) | 2590 | 4904 | +89% |
| Perfect-5th beat (mHz) | 446 | 841 | +89% |

Spectral features scale proportionally with root frequency, consistent with equal temperament's multiplicative frequency structure. Major-third beating (2.6–4.9 Hz) falls within the roughness-sensitive range of the Plomp–Levelt model; whether this difference is perceptible in practice is not addressed by this analysis.

---

## Figures

| Figure | Description |
|---|---|
| Fig 1 | Synthesized waveforms for 4 selected keys |
| Fig 2 | Overlaid FFT spectra for all 12 keys (0–4 kHz) |
| Fig 3 | FFT spectra for 4 keys with f₀ markers |
| Fig 4 | STFT spectrograms for 4 keys (0–5 kHz) |
| Fig 5 | Spectral centroid, bandwidth, rolloff across all 12 keys |
| Fig 6 | Harmonic partial heatmap normalized to fundamental |
| Fig 7 | Root-note FFT showing harmonic series for all 12 keys |
| Fig 8 | Equal-temperament beating vs. just intonation for all 12 keys |

---

## Data

Load the saved variables:

```matlab
load('results/spectral_data.mat');
```

Variables: `keys`, `key_roots`, `centroid`, `bandwidth`, `rolloff`, `beat_third`, `beat_fifth`, `par_norm`, `fft_cache`, `f_root`, `f_third`, `f_fifth`, `Fs`, `bpm`, `A4`.

---

## Background

The notion that different musical keys carry distinct characters has been discussed since at least Mattheson (1713) and Schubart (1806). Three mechanisms are typically proposed: unequal historical temperaments making some keys purer than others; instrument-specific resonances varying by key; and absolute pitch perception. This project examines a simpler underlying factor — that equal-temperament transposition shifts the entire spectral mass of a melody upward in proportion to the root frequency, changing the signal's spectral centroid, bandwidth, and inter-interval beating regardless of instrument or tuning system. The analysis is purely computational and does not test whether listeners perceive these differences.

---

## Citation

```
Kamaleldin, K. (2026). fourier-key-analysis.
GitHub. https://github.com/KemoTherapy/FourierSongs
```

---

## References

- Plomp, R. & Levelt, W. J. M. (1965). Tonal consonance and critical bandwidth. *JASA*, 38(4), 548–560.
- Helmholtz, H. L. F. (1885). *On the Sensations of Tone*. Longmans, Green.
- Schubart, C. F. D. (1806). *Ideen zu einer Ästhetik der Tonkunst*. J. V. Degen.
- Benson, D. J. (2007). *Music: A Mathematical Offering*. Cambridge University Press.

Full references in the accompanying writeup .

---

## License

MIT
