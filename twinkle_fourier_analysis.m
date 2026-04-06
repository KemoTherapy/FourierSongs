% twinkle_fourier_analysis.m
%
% Spectral analysis of "Twinkle Twinkle Little Star" across all 12 chromatic
% major keys using FFT and STFT. Synthesizes each key via additive synthesis,
% extracts spectral features, and writes figures + data to results/.
%
% Requires: Signal Processing Toolbox (spectrogram, hann)
% Tested:   MATLAB R2022b
% Output:   results/Fig1–8.png, results/spectral_data.mat

clear; clc; close all;

%% Parameters

Fs       = 44100;     % sample rate (Hz)
A4       = 440.0;     % reference pitch, ISO 16:1975
bpm      = 120;
beat_s   = 60 / bpm;  % seconds per beat
amp      = 0.5;       % peak amplitude after normalisation

if ~exist('results', 'dir'), mkdir('results'); end

midi2hz = @(n) A4 * 2 .^ ((n - 69) / 12);

%% Melody definition
% "Twinkle Twinkle Little Star" encoded as semitone offsets from tonic.
% Scale degrees used: 0(1), 2(2), 4(3), 5(4), 7(5), 9(6).

mel_st = [0 0 7 7 9 9 7  5 5 4 4 2 2 0 ...
          7 7 5 5 4 4 2  7 7 5 5 4 4 2 ...
          0 0 7 7 9 9 7  5 5 4 4 2 2 0];

mel_beats = [1 1 1 1 1 1 2  1 1 1 1 1 1 2 ...
             1 1 1 1 1 1 2  1 1 1 1 1 1 2 ...
             1 1 1 1 1 1 2  1 1 1 1 1 1 2];

%% Key definitions (C4 = MIDI 60 through B4 = MIDI 71)

keys      = {'C','C#/Db','D','D#/Eb','E','F','F#/Gb','G','G#/Ab','A','A#/Bb','B'};
key_roots = 60:71;
n_keys    = numel(keys);

%% Synthesis
% Additive model: s(t) = sum_h a_h * sin(2*pi*h*f0*t), h=1..5
% Partial amplitudes follow geometric decay (1/2^(h-1)).
% ADSR: 10ms attack, 50ms decay to 0.75 sustain, 80ms release.

h_amp = [1.0 0.5 0.25 0.125 0.0625];

signals    = cell(1, n_keys);
fft_cache  = cell(1, n_keys);

fprintf('Synthesising...\n');
for k = 1:n_keys
    sig = [];
    for n = 1:numel(mel_st)
        f0  = midi2hz(key_roots(k) + mel_st(n));
        dur = mel_beats(n) * beat_s;
        t   = (0 : round(dur * Fs) - 1) / Fs;

        wave = zeros(size(t));
        for h = 1:numel(h_amp)
            wave = wave + h_amp(h) * sin(2 * pi * h * f0 * t);
        end
        wave = adsr(wave, Fs);
        sig  = [sig, wave]; %#ok<AGROW>
    end
    sig = amp * sig / max(abs(sig));
    signals{k} = sig;

    N   = numel(sig);
    Y   = fft(sig, N);
    f   = (0 : N/2) * Fs / N;
    mag = (2/N) * abs(Y(1 : N/2 + 1));
    fft_cache{k}.f   = f;
    fft_cache{k}.mag = mag;
end
fprintf('Done.\n\n');

%% Figure 1 — waveforms for four representative keys

sel = [1 4 7 10];  % C, Eb, F#, A
fig1 = figure('Name','Fig1','Position',[50 50 1200 800]);
for i = 1:4
    k   = sel(i);
    t   = (0 : numel(signals{k}) - 1) / Fs;
    subplot(4, 1, i);
    plot(t, signals{k}, 'Color', key_rgb(k), 'LineWidth', 0.6);
    ylabel('Amplitude');
    title(sprintf('Key of %s Major', keys{k}), 'FontWeight', 'bold');
    xlim([0 t(end)]); ylim([-0.6 0.6]); grid on;
    if i == 4, xlabel('Time (s)'); end
end
sgtitle('Figure 1. Synthesized Waveforms of "Twinkle Twinkle Little Star" in Selected Keys');
saveas(fig1, 'results/Fig1_Waveforms.png');

%% Figure 2 — FFT overlay, all 12 keys

fig2 = figure('Name','Fig2','Position',[50 50 1200 600]);
hold on;
for k = 1:n_keys
    plot(fft_cache{k}.f, db(fft_cache{k}.mag), ...
        'Color', key_rgb(k), 'LineWidth', 0.9, 'DisplayName', keys{k});
end
hold off;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dBFS)');
title('Figure 2. FFT Magnitude Spectra of All 12 Major Keys');
legend(keys, 'Location', 'northeast', 'NumColumns', 3, 'FontSize', 8);
xlim([0 4000]); ylim([-90 -20]); grid on;
saveas(fig2, 'results/Fig2_FFT_AllKeys.png');

%% Figure 3 — FFT, four selected keys with f0 markers

fig3 = figure('Name','Fig3','Position',[50 50 1200 900]);
for i = 1:4
    k   = sel(i);
    f0r = midi2hz(key_roots(k));
    subplot(4, 1, i);
    plot(fft_cache{k}.f, db(fft_cache{k}.mag), 'Color', key_rgb(k), 'LineWidth', 1.1);
    xline(f0r, '--k', 'LineWidth', 1.4, 'Label', sprintf('f_0=%.0f Hz', f0r));
    ylabel('dBFS');
    title(sprintf('Key of %s Major', keys{k}), 'FontWeight', 'bold');
    xlim([0 5000]); ylim([-90 -20]); grid on;
    if i == 4, xlabel('Frequency (Hz)'); end
end
sgtitle('Figure 3. FFT Spectra with Root Note Fundamental Marked');
saveas(fig3, 'results/Fig3_FFT_4Keys.png');

%% Figure 4 — STFT spectrograms, four selected keys

win  = round(0.05 * Fs);
hop  = round(0.01 * Fs);
nfft = 2^nextpow2(win);

fig4 = figure('Name','Fig4','Position',[50 50 1200 900]);
for i = 1:4
    k = sel(i);
    subplot(4, 1, i);
    spectrogram(signals{k}, hann(win), win - hop, nfft, Fs, 'yaxis');
    ylim([0 5]);
    title(sprintf('Key of %s Major', keys{k}), 'FontWeight', 'bold');
    colorbar off;
    if i ~= 4, xlabel(''); end
end
sgtitle('Figure 4. STFT Spectrograms of Selected Keys (0–5 kHz)');
colormap(jet);
saveas(fig4, 'results/Fig4_Spectrogram.png');

%% Spectral features

centroid  = zeros(1, n_keys);
bandwidth = zeros(1, n_keys);
rolloff   = zeros(1, n_keys);

for k = 1:n_keys
    f   = fft_cache{k}.f;
    p   = fft_cache{k}.mag .^ 2;   % power spectrum
    pn  = p / sum(p);

    centroid(k)  = sum(f .* pn);
    bandwidth(k) = sqrt(sum((f - centroid(k)).^2 .* pn));

    cp = cumsum(p);
    rolloff(k) = f(find(cp >= 0.85 * cp(end), 1));
end

%% Figure 5 — spectral feature bar charts

fig5 = figure('Name','Fig5','Position',[50 50 1200 900]);
features = {centroid, bandwidth, rolloff};
labels   = {'Centroid (Hz)', 'Bandwidth (Hz)', '85% Rolloff (Hz)'};
titles   = {'Spectral Centroid per Key', 'Spectral Bandwidth per Key', ...
            '85% Spectral Rolloff Frequency per Key'};
colours  = {[0.20 0.47 0.76], [0.74 0.25 0.17], [0.15 0.62 0.32]};

for i = 1:3
    subplot(3, 1, i);
    bar(1:n_keys, features{i}, 'FaceColor', colours{i}, 'EdgeColor', 'none');
    xticks(1:n_keys); xticklabels(keys); xtickangle(30);
    ylabel(labels{i}); title(titles{i}, 'FontWeight', 'bold'); grid on;
end
sgtitle('Figure 5. Spectral Feature Comparison Across All 12 Major Keys');
saveas(fig5, 'results/Fig5_SpectralFeatures.png');

%% Harmonic partial amplitudes (root note, 8 partials)

n_par  = 8;
par_db = zeros(n_keys, n_par);

for k = 1:n_keys
    f0  = midi2hz(key_roots(k));
    dur = 1 * beat_s;
    t   = (0 : round(dur * Fs) - 1) / Fs;
    wave = zeros(size(t));
    for h = 1:numel(h_amp)
        wave = wave + h_amp(h) * sin(2 * pi * h * f0 * t);
    end
    wave = adsr(wave, Fs);

    N   = numel(wave);
    Y   = fft(wave, N);
    fr  = (0 : N/2) * Fs / N;
    mag = (2/N) * abs(Y(1 : N/2 + 1));

    for p = 1:n_par
        idx = fr >= p*f0 - 5 & fr <= p*f0 + 5;
        if any(idx)
            par_db(k, p) = max(mag(idx));
        end
    end
end
par_norm = par_db ./ (par_db(:, 1) + eps);

%% Figure 6 — harmonic partial heatmap

fig6 = figure('Name','Fig6','Position',[50 50 1200 600]);
imagesc(1:n_par, 1:n_keys, 20 * log10(par_norm + 1e-12));
colormap(hot); colorbar;
xlabel('Harmonic Partial Number'); ylabel('Key');
yticks(1:n_keys); yticklabels(keys); xticks(1:n_par);
title('Figure 6. Relative Amplitude of Harmonic Partials per Key (dBFS, normalised to fundamental)');
saveas(fig6, 'results/Fig6_HarmonicPartials.png');

%% Figure 7 — root-note FFT, all 12 keys

fig7 = figure('Name','Fig7','Position',[50 50 1400 700]);
cmap = lines(n_keys);
hold on;
for k = 1:n_keys
    f0   = midi2hz(key_roots(k));
    dur  = beat_s;
    t    = (0 : round(dur * Fs) - 1) / Fs;
    wave = zeros(size(t));
    for h = 1:numel(h_amp)
        wave = wave + h_amp(h) * sin(2 * pi * h * f0 * t);
    end
    wave = adsr(wave, Fs);
    N    = numel(wave);
    Y    = fft(wave, N);
    fr   = (0 : N/2) * Fs / N;
    mag  = (2/N) * abs(Y(1 : N/2 + 1));
    plot(fr, db(mag + 1e-12), 'Color', cmap(k,:), 'LineWidth', 1.1, ...
        'DisplayName', sprintf('%s (f_0=%.1f Hz)', keys{k}, f0));
end
hold off;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dBFS)');
xlim([0 6000]); ylim([-80 -10]);
legend('Location', 'northeast', 'NumColumns', 2, 'FontSize', 7);
title('Figure 7. FFT of Isolated Root Note for Each Key — Harmonic Partial Series');
grid on;
saveas(fig7, 'results/Fig7_RootNoteFFT.png');

%% Equal-temperament beating vs. just intonation
% Major third: just ratio 5:4; perfect fifth: just ratio 3:2.
% beat_f = |f_interval_ET - ratio * f_root|

f_root  = arrayfun(@(k) midi2hz(key_roots(k)),   1:n_keys);
f_third = arrayfun(@(k) midi2hz(key_roots(k)+4), 1:n_keys);
f_fifth = arrayfun(@(k) midi2hz(key_roots(k)+7), 1:n_keys);

beat_third = abs(f_third - (5/4) * f_root) * 1000;   % mHz
beat_fifth = abs(f_fifth - (3/2) * f_root) * 1000;

%% Figure 8 — beating bar charts

fig8 = figure('Name','Fig8','Position',[50 50 1200 700]);
subplot(1, 2, 1);
bar(1:n_keys, beat_third, 'FaceColor', [0.90 0.50 0.15], 'EdgeColor', 'none');
xticks(1:n_keys); xticklabels(keys); xtickangle(45);
ylabel('Beat Frequency (mHz)');
title({'Major Third Beating vs. Just Intonation', 'Equal Temperament Deviation'}, ...
    'FontWeight', 'bold');
grid on;

subplot(1, 2, 2);
bar(1:n_keys, beat_fifth, 'FaceColor', [0.18 0.55 0.85], 'EdgeColor', 'none');
xticks(1:n_keys); xticklabels(keys); xtickangle(45);
ylabel('Beat Frequency (mHz)');
title({'Perfect Fifth Beating vs. Just Intonation', 'Equal Temperament Deviation'}, ...
    'FontWeight', 'bold');
grid on;
sgtitle('Figure 8. Equal-Temperament Deviation from Just Intonation Across All 12 Keys');
saveas(fig8, 'results/Fig8_Beating.png');

%% Console summary

fprintf('%-12s %10s %12s %10s %13s %12s\n', ...
    'Key','Centroid','Bandwidth','Rolloff','3rd Beat(mHz)','5th Beat(mHz)');
fprintf('%s\n', repmat('-',1,71));
for k = 1:n_keys
    fprintf('%-12s %10.1f %12.1f %10.1f %13.1f %12.1f\n', ...
        keys{k}, centroid(k), bandwidth(k), rolloff(k), beat_third(k), beat_fifth(k));
end

%% Save data

save('results/spectral_data.mat', ...
    'keys','key_roots','centroid','bandwidth','rolloff', ...
    'beat_third','beat_fifth','par_norm','f_root','f_third','f_fifth', ...
    'fft_cache','Fs','bpm','A4');

fprintf('\nAll outputs written to results/\n');

%% ---- local functions ----

function wave = adsr(wave, Fs)
% Apply ADSR envelope in-place.
% Attack 10ms, decay 50ms to 0.75 sustain, release 80ms.
    N   = numel(wave);
    att = min(round(0.010 * Fs), N);
    dec = min(round(0.050 * Fs), N);
    rel = min(round(0.080 * Fs), N);
    sus = 0.75;

    env = sus * ones(1, N);
    env(1:att) = linspace(0, 1, att);
    d_end = min(att + dec, N);
    env(att+1 : d_end) = linspace(1, sus, d_end - att);
    if N > rel
        env(N-rel+1 : N) = linspace(sus, 0, rel);
    end
    wave = wave .* env;
end

function c = key_rgb(k)
% Return an HSV-derived colour for key index k (1–12).
    cmap = hsv(12);
    c = cmap(k, :);
end

function y = db(x)
% Convert linear amplitude to dBFS. Adds epsilon to avoid log(0).
    y = 20 * log10(abs(x) + 1e-12);
end
