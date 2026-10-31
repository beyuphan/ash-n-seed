# -*- coding: utf-8 -*-
"""Oyunun müzik döngülerini kodla üretir (chiptune): assets/audio/music/*.ogg
Çalıştır:  python tools/make_music.py      (numpy ve ffmpeg gerekir)
Her parça: akor ilerlemesi + bas + arpej + melodi (tohumlu, motif tekrarlı) + davul. Döngü dikişsizdir (kuyruklar başa sarılır).
Parçalar: menu_theme, desk_theme, paper_theme, field_jaunty, field_tense  (field_calm = eski calm_loop.ogg)
"""
import os
import random
import subprocess
import sys
import wave

import numpy as np

SR = 32000
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "audio", "music")

MAJOR = [0, 2, 4, 5, 7, 9, 11]
MINOR = [0, 2, 3, 5, 7, 8, 10]
PENT_MAJOR = [0, 2, 4, 7, 9]
PENT_MINOR = [0, 3, 5, 7, 10]


def hz(m):
    return 440.0 * 2 ** ((m - 69) / 12.0)


def scale_note(root, scale, degree):
    """degree 0.. -> midi (oktav aşan dereceler desteklenir)."""
    octave, idx = divmod(degree, len(scale))
    return root + scale[idx] + 12 * octave


def osc(kind, f, n, duty=0.5, vib=0.0):
    t = np.arange(n) / SR
    freq = f * (1 + 0.006 * vib * np.sin(2 * np.pi * 5.5 * t)) if vib else np.full(n, f)
    ph = (np.cumsum(freq) / SR) % 1.0
    if kind == "square":
        return np.where(ph < duty, 1.0, -1.0)
    if kind == "tri":
        return 4 * np.abs(ph - 0.5) - 1
    if kind == "saw":
        return 2 * ph - 1
    return np.sin(2 * np.pi * ph)


def adsr(n, a=0.005, d=0.08, s=0.6, r=0.06):
    e = np.ones(n)
    na, nd, nr = int(a * SR), int(d * SR), int(r * SR)
    na = min(na, n)
    e[:na] = np.linspace(0, 1, na) if na else e[:na]
    nd = min(nd, max(n - na, 0))
    if nd:
        e[na:na + nd] = np.linspace(1, s, nd)
    e[na + nd:] = s
    nr = min(nr, n)
    if nr:
        e[n - nr:] *= np.linspace(1, 0, nr)
    return e


class Mix:
    def __init__(self, bpm, beats, tail=1.5, swing=0.0):
        self.bpm, self.beats, self.swing = bpm, beats, swing
        self.spb = 60.0 / bpm
        self.loop_n = int(round(beats * self.spb * SR))
        self.buf = np.zeros(self.loop_n + int(tail * SR))

    def t(self, beat):
        if self.swing and (beat * 2) % 2 == 1:   # sekizliklerin ikincisi geç gelir
            beat += self.swing * 0.5
        return int(beat * self.spb * SR)

    def add(self, beat, dur, midi, kind="square", vol=0.3, duty=0.5, a=0.004, d=0.08, s=0.6, r=0.06, vib=0.0):
        start = self.t(beat)
        n = max(int(dur * self.spb * SR), 8)
        sig = osc(kind, hz(midi), n, duty, vib) * adsr(n, a, d, s, r) * vol
        end = min(start + n, len(self.buf))
        self.buf[start:end] += sig[:end - start]

    def kick(self, beat, vol=0.5):
        start, n = self.t(beat), int(0.18 * SR)
        t = np.arange(n) / SR
        f = 50 + 110 * np.exp(-t * 28)
        sig = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 16) * vol
        self.buf[start:start + n] += sig[:len(self.buf) - start]

    def snare(self, beat, vol=0.3):
        start, n = self.t(beat), int(0.16 * SR)
        t = np.arange(n) / SR
        noise = np.random.uniform(-1, 1, n) * np.exp(-t * 22)
        tone = np.sin(2 * np.pi * 190 * t) * np.exp(-t * 28)
        self.buf[start:start + n] += ((noise * 0.8 + tone * 0.5) * vol)[:len(self.buf) - start]

    def hat(self, beat, vol=0.12, open_=False):
        start, n = self.t(beat), int((0.14 if open_ else 0.04) * SR)
        t = np.arange(n) / SR
        noise = np.random.uniform(-1, 1, n)
        noise = noise - np.concatenate(([0], noise[:-1])) * 0.9   # basit yüksek geçiren
        self.buf[start:start + n] += (noise * np.exp(-t * (25 if open_ else 90)) * vol)[:len(self.buf) - start]

    def render(self):
        out = self.buf[:self.loop_n].copy()
        tail = self.buf[self.loop_n:]
        out[:len(tail)] += tail                              # kuyruk başa sarılır
        out = np.tanh(out * 1.3) / 1.3                       # yumuşak sınırlama
        peak = np.max(np.abs(out)) or 1.0
        return out / peak * 0.8


def triad(root, scale, degree):
    return [scale_note(root, scale, degree + k) for k in (0, 2, 4)]


def make_melody(rng, root, scale, bars, chord_for_bar, octave=12, rest_p=0.12):
    """Motifli melodi: 4 barlık A ve B cümleleri dönüşümlü tekrar eder, son ölçü tonikte çözülür. Dönüş: [(beat, dur, midi|None)]."""
    patterns = [[1, 1, 1, 1], [1.5, .5, 1, 1], [.5, .5, 1, .5, .5, 1], [2, 1, 1], [1, .5, .5, .5, .5, 1], [.5, .5, .5, .5, 1, 1]]

    def phrase(seed, start_deg, first_bar):
        r = random.Random(seed)
        notes = []
        deg = start_deg
        for bar in range(4):
            chord_deg = chord_for_bar(first_bar + bar)
            beat = 0.0
            for dur in r.choice(patterns):
                strong = abs(beat - round(beat)) < 1e-6 and int(beat) % 2 == 0
                if strong:   # güçlü vuruşta akor sesine yaslan
                    cands = [chord_deg + k + 7 * o for k in (0, 2, 4) for o in (0, 1)]
                    deg = min(cands, key=lambda c: abs(c - deg) + r.random() * 1.2)
                else:
                    deg += r.choice([-2, -1, -1, 1, 1, 2])
                deg = max(-2, min(deg, 11))
                rest = r.random() < rest_p and not strong
                notes.append((bar * 4 + beat, dur * 0.92, None if rest else scale_note(root + octave, scale, deg)))
                beat += dur
        return notes

    seed_a, seed_b = rng.randint(0, 99999), rng.randint(0, 99999)
    out = []
    for section in range(bars // 4):
        base = phrase(seed_a if section % 2 == 0 else seed_b, 4 if section % 2 == 0 else 2, section * 4)
        out += [(b + section * 16, d, m) for (b, d, m) in base]
    out = [n for n in out if n[0] < (bars - 1) * 4]
    out.append(((bars - 1) * 4, 3.0, scale_note(root + octave, scale, 0)))
    return out


def build(name, bpm, root, scale, melody_scale, prog, drums, bass_style, arp_style, lead, bars=16, swing=0.0, seed=1, lead_vol=0.22, minor=False):
    rng = random.Random(seed)
    np.random.seed(seed)
    beats = bars * 4
    m = Mix(bpm, beats, swing=swing)

    def chord_for_bar(bar):
        return prog[bar % len(prog)]

    # --- bas
    for bar in range(bars):
        deg = chord_for_bar(bar)
        r0 = scale_note(root - 24, scale, deg)
        b = bar * 4
        if bass_style == "root5":
            for beat, midi in ((0, r0), (1.5, r0), (2, r0 + 7), (3.5, r0 + 7)):
                m.add(b + beat, 0.9, midi, "tri", 0.34, d=0.1, s=0.7)
        elif bass_style == "walk":
            third = scale_note(root - 24, scale, deg + 2)
            fifth = scale_note(root - 24, scale, deg + 4)
            for k, midi in enumerate((r0, third, fifth, scale_note(root - 24, scale, deg + 5))):
                m.add(b + k, 0.8, midi, "tri", 0.34, d=0.08, s=0.6)
        elif bass_style == "drive":
            for k in range(8):
                midi = r0 + (12 if k % 4 == 3 else 0)
                m.add(b + k * 0.5, 0.45, midi, "square", 0.16, duty=0.25, d=0.06, s=0.3, r=0.03)
        elif bass_style == "oompah":
            m.add(b, 0.9, r0, "tri", 0.36)
            m.add(b + 1, 0.4, r0 + 12 + 7, "square", 0.1, duty=0.25, d=0.05, s=0.2)
            m.add(b + 2, 0.9, r0 + 7, "tri", 0.36)
            m.add(b + 3, 0.4, r0 + 12 + 7, "square", 0.1, duty=0.25, d=0.05, s=0.2)

    # --- arpej
    for bar in range(bars):
        deg = chord_for_bar(bar)
        ch = triad(root, scale, deg)
        b = bar * 4
        if arp_style == "eighth":
            seq = [ch[0], ch[1], ch[2], ch[1] + 12]
            for k in range(8):
                m.add(b + k * 0.5, 0.4, seq[k % 4] + 12, "square", 0.075, duty=0.125, d=0.05, s=0.25, r=0.03)
        elif arp_style == "sixteenth":
            seq = [ch[0], ch[2], ch[1] + 12, ch[2]]
            for k in range(16):
                m.add(b + k * 0.25, 0.22, seq[k % 4] + 12, "square", 0.06, duty=0.125, d=0.04, s=0.2, r=0.02)
        elif arp_style == "stab":
            for beat in (1, 3):
                for midi in ch:
                    m.add(b + beat, 0.35, midi + 12, "square", 0.07, duty=0.25, d=0.06, s=0.3)
        elif arp_style == "pad":
            for midi in ch:
                m.add(b, 3.9, midi, "tri", 0.06, a=0.2, d=0.5, s=0.7, r=0.3)

    # --- melodi
    melody = make_melody(rng, root, melody_scale, bars, chord_for_bar)
    for beat, dur, midi in melody:
        if midi is None:
            continue
        kind, duty, vib = lead
        m.add(beat, dur, midi, kind, lead_vol, duty=duty, a=0.01, d=0.12, s=0.7, r=0.08, vib=vib)

    # --- davul
    for bar in range(bars):
        b = bar * 4
        if drums == "march":
            for beat in (0, 2):
                m.kick(b + beat)
            for beat in (1, 3):
                m.snare(b + beat, 0.22)
            for k in range(8):
                m.hat(b + k * 0.5, 0.08)
        elif drums == "bounce":
            m.kick(b)
            m.kick(b + 1.5)
            m.kick(b + 2)
            m.snare(b + 1, 0.2)
            m.snare(b + 3, 0.2)
            for k in range(8):
                m.hat(b + k * 0.5, 0.07 + 0.04 * (k % 2))
        elif drums == "drive":
            for beat in (0, 1, 2, 3):
                m.kick(b + beat, 0.45)
            m.snare(b + 1, 0.26)
            m.snare(b + 3, 0.26)
            for k in range(16):
                m.hat(b + k * 0.25, 0.05 + (0.04 if k % 4 == 2 else 0.0), open_=(k % 8 == 6))
        elif drums == "soft":
            m.kick(b, 0.35)
            m.kick(b + 2.5, 0.3)
            m.snare(b + 2, 0.12)
            for k in range(4):
                m.hat(b + k + 0.5, 0.06)
    return m.render()


# ----------------------------------------------------------------------------- Özel parçalar: karamsar intro, cıvıl cıvıl outro
def crash(m, beat, vol=0.2):
    start, n = m.t(beat), int(1.3 * SR)
    t = np.arange(n) / SR
    noise = np.random.uniform(-1, 1, n)
    noise = noise - np.concatenate(([0], noise[:-1])) * 0.85
    m.buf[start:start + n] += (noise * np.exp(-t * 3.2) * vol)[:len(m.buf) - start]


def riser(m, beat, beats, vol=0.15):
    """Gerilim yükselticisi: gürültü giderek yükselir (patlamadan önce)."""
    start, n = m.t(beat), int(beats * m.spb * SR)
    t = np.linspace(0, 1, n)
    noise = np.random.uniform(-1, 1, n)
    noise = np.convolve(noise, np.ones(6) / 6, mode="same")
    m.buf[start:start + n] += (noise * t ** 2.2 * vol)[:len(m.buf) - start]


def wind_bed(m, vol=0.06):
    """Sürekli, yavaş dalgalanan rüzgâr/sis uğultusu (düşük geçiren gürültü)."""
    n = m.loop_n
    noise = np.convolve(np.random.uniform(-1, 1, n), np.ones(70) / 70, mode="same")
    t = np.arange(n) / SR
    swell = 0.55 + 0.45 * np.sin(2 * np.pi * t / (n / SR) * 3 + 1.0)
    m.buf[:n] += noise * swell * vol


def chirp(m, beat, f0, f1, dur=0.09, vol=0.07):
    """Kuş cıvıltısı: hızlı kayan sinüs."""
    start, n = m.t(beat), int(dur * SR)
    t = np.arange(n) / SR
    f = np.linspace(f0, f1, n)
    sig = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * t / dur) ** 0.7 * vol
    sig += np.sin(4 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * t / dur) * vol * 0.2
    m.buf[start:start + n] += sig[:len(m.buf) - start]


def build_dark():
    """Intro: karamsar ve dramatik. Re minör, 58 bpm, 16 ölçü. Düşük drone, ağır pad, yalnız yakarış melodisi, kalp atışı, yükselen gerilim."""
    np.random.seed(61)
    bars = 16
    m = Mix(58, bars * 4, tail=2.5)
    # Drone: tüm döngü boyunca, başta ve sonda yumuşakça açılıp kapanır
    m.add(0, bars * 4 - 0.5, 26, "sine", 0.34, a=3.0, d=1.0, s=0.95, r=2.5)
    m.add(0, bars * 4 - 0.5, 33, "sine", 0.13, a=4.0, d=1.0, s=0.95, r=2.5)
    m.add(0, bars * 4 - 0.5, 38, "tri", 0.09, a=4.0, d=1.0, s=0.9, r=2.5, vib=0.3)
    chords = [[50, 57, 62, 65], [46, 53, 58, 62], [43, 50, 55, 58], [45, 52, 57, 61]]   # Dm Bb Gm A
    for bar in range(bars):
        tones = chords[(bar // 2) % 4]
        if bar % 2 == 0:
            heavy = bar >= 8
            for tn in tones:
                m.add(bar * 4, 7.7, tn, "tri", 0.08 if heavy else 0.06, a=1.4, d=1.0, s=0.8, r=1.2, vib=0.5)
                m.add(bar * 4, 7.7, tn, "saw", 0.028 if heavy else 0.018, a=1.8, d=1.0, s=0.8, r=1.2, vib=0.7)
                m.add(bar * 4, 7.7, tn - 12, "tri", 0.05, a=1.0, d=1.0, s=0.8, r=1.2)
    # Yakarış melodisi (bar, vuruş, süre, nota)
    lament = [
        (0, 0, 3, 69), (0, 3, 1, 67), (1, 0, 2, 65), (1, 2, 2, 64),
        (2, 0, 3, 74), (2, 3, 1, 72), (3, 0, 2, 70), (3, 2, 2, 69),
        (4, 0, 2, 67), (4, 2, 2, 70), (5, 0, 3, 74), (5, 3, 1, 72),
        (6, 0, 2, 73), (6, 2, 1, 76), (6, 3, 1, 74), (7, 0, 4, 69),
        (8, 0, 3, 81), (8, 3, 1, 79), (9, 0, 2, 77), (9, 2, 2, 76),
        (10, 0, 3, 86), (10, 3, 1, 84), (11, 0, 2, 82), (11, 2, 2, 81),
        (12, 0, 2, 79), (12, 2, 2, 82), (13, 0, 3, 86), (13, 3, 1, 84),
        (14, 0, 2, 85), (14, 2, 1, 88), (14, 3, 1, 86), (15, 0, 4, 74),
    ]
    for bar, b, d, mid in lament:
        loud = 0.2 if bar >= 8 else 0.15
        m.add(bar * 4 + b, d * 0.97, mid, "tri", loud, a=0.08, d=0.3, s=0.8, r=0.5, vib=1.0)
        m.add(bar * 4 + b, d * 0.97, mid - 12, "sine", 0.07, a=0.1, d=0.3, s=0.8, r=0.5, vib=0.6)
    # Kalp atışı ve ağır davullar
    for bar in range(bars):
        b0 = bar * 4
        if bar >= 8:
            m.kick(b0, 0.75)
            m.kick(b0 + 0.45, 0.4)
            if bar % 2 == 1:
                m.kick(b0 + 2, 0.5)
        elif bar % 2 == 0:
            m.kick(b0, 0.55)
            m.kick(b0 + 0.45, 0.28)
    m.kick(8 * 4, 1.0)
    m.kick(12 * 4, 1.0)
    # Gerilim: bölüm geçişlerinde yükselti ve zil, dissonant küme
    riser(m, 7 * 4 + 1, 3, 0.2)
    crash(m, 8 * 4, 0.28)
    riser(m, 14 * 4, 8, 0.24)
    for bar in (4, 12):
        m.add(bar * 4, 4, 38, "saw", 0.07, a=0.05, d=1.0, s=0.5, r=1.0)
        m.add(bar * 4, 4, 39, "saw", 0.06, a=0.05, d=1.0, s=0.5, r=1.0)
    for k in range(16):   # son ölçülerde trampet gerilimi
        m.snare(15 * 4 + k * 0.25, 0.04 + 0.012 * k)
    wind_bed(m, 0.07)
    return m.render() * 0.78


def build_joy():
    """Outro: cıvıl cıvıl, neşeli. Do majör, 126 bpm, 32 ölçü. Zıplayan bas, ukulele vuruşları, çan, ıslık ve kuş cıvıltıları."""
    np.random.seed(71)
    rng = random.Random(71)
    bars = 32
    m = Mix(126, bars * 4, swing=0.25, tail=1.5)
    prog_a = ["C", "F", "C", "G", "Am", "F", "G", "C"]
    prog_b = ["C", "Am", "F", "G", "C", "F", "G", "C"]
    chords = {"C": (36, [60, 64, 67]), "F": (41, [60, 65, 69]), "G": (43, [59, 62, 67]), "Am": (45, [60, 64, 69])}
    theme_a = [
        [(0, .5, 76), (.5, .5, 79), (1, .5, 76), (1.5, .5, 72), (2, .5, 74), (2.5, .5, 76), (3, 1, 79)],
        [(0, .5, 81), (.5, .5, 77), (1, .5, 81), (1.5, .5, 84), (2, 1, 81), (3, 1, 77)],
        [(0, .5, 79), (.5, .5, 76), (1, .5, 79), (1.5, .5, 84), (2, .5, 83), (2.5, .5, 79), (3, 1, 76)],
        [(0, .5, 74), (.5, .5, 79), (1, .5, 83), (1.5, .5, 86), (2, 1, 83), (3, 1, 79)],
        [(0, .5, 84), (.5, .5, 83), (1, .5, 81), (1.5, .5, 76), (2, 1, 81), (3, 1, 84)],
        [(0, .5, 81), (.5, .5, 79), (1, .5, 77), (1.5, .5, 81), (2, 2, 84)],
        [(0, .5, 83), (.5, .5, 81), (1, .5, 79), (1.5, .5, 83), (2, 1, 86), (3, 1, 83)],
        [(0, 1, 84), (1, .5, 79), (1.5, .5, 76), (2, 2, 72)],
    ]
    theme_b = [
        [(0, .5, 79), (.5, .5, 79), (1, .5, 84), (1.5, .5, 84), (2, 1, 88), (3, 1, 84)],
        [(0, .5, 81), (.5, .5, 81), (1, .5, 84), (1.5, .5, 84), (2, 1, 88), (3, 1, 81)],
        [(0, .5, 77), (.5, .5, 81), (1, .5, 84), (1.5, .5, 81), (2, 1, 89), (3, 1, 84)],
        [(0, .5, 83), (.5, .5, 86), (1, .5, 91), (1.5, .5, 86), (2, 1, 83), (3, 1, 79)],
        [(0, .5, 88), (.5, .5, 88), (1, .5, 86), (1.5, .5, 84), (2, 1, 86), (3, 1, 88)],
        [(0, .5, 89), (.5, .5, 88), (1, .5, 86), (1.5, .5, 84), (2, 1, 81), (3, 1, 84)],
        [(0, .5, 83), (.5, .5, 84), (1, .5, 86), (1.5, .5, 88), (2, 1, 86), (3, 1, 83)],
        [(0, 1, 84), (1, 1, 88), (2, 2, 84)],
    ]
    sections = [("A", 0, False), ("B", 8, True), ("A", 16, True), ("B", 24, True)]
    for name, first, rich in sections:
        prog = prog_a if name == "A" else prog_b
        theme = theme_a if name == "A" else theme_b
        if first > 0:
            crash(m, first * 4, 0.12)
        for i, chord in enumerate(prog):
            bar = first + i
            b0 = bar * 4
            root, tones = chords[chord]
            # Zıplayan pizzicato bas
            for beat, mid in ((0, root), (1.5, root + 12), (2, root + 7), (3.5, root + 12)):
                m.add(b0 + beat, 0.45, mid, "tri", 0.34, a=0.003, d=0.06, s=0.25, r=0.05)
            # Ukulele vuruşları: zayıf zamanlarda kısa akorlar
            for beat in (0.5, 1.5, 2.5, 3.5):
                for tn in tones:
                    m.add(b0 + beat, 0.22, tn, "square", 0.036, duty=0.125, a=0.002, d=0.05, s=0.2, r=0.03)
            # Melodi: sekmeli, kısa notalar (staccato) + oktav üstü ıslık
            for b, d, mid in theme[i]:
                m.add(b0 + b, d * 0.72, mid, "square", 0.12, duty=0.25, a=0.004, d=0.06, s=0.55, r=0.04)
                m.add(b0 + b, d * 0.9, mid + 12, "sine", 0.05, a=0.01, d=0.1, s=0.6, r=0.05, vib=0.6)
                if rich and name == "A" and first >= 16:   # ikinci turda ıslık sesi ek katman
                    m.add(b0 + b, d * 0.9, mid, "sine", 0.07, a=0.02, d=0.1, s=0.7, r=0.06, vib=1.0)
            # Çan arpeji
            if rich:
                seq = [tones[0] + 24, tones[2] + 12, tones[1] + 24, tones[2] + 24]
                for k in range(8):
                    m.add(b0 + k * 0.5, 0.45, seq[k % 4], "sine", 0.06, a=0.002, d=0.18, s=0.15, r=0.15)
            # Hafif davul: tek vuruş + el çırpma + çıngırak
            m.kick(b0, 0.32)
            m.kick(b0 + 2, 0.28)
            m.snare(b0 + 1, 0.09)
            m.snare(b0 + 3, 0.09)
            for k in range(8):
                m.hat(b0 + k * 0.5, 0.035 + 0.025 * (k % 2))
            # Kuş cıvıltıları: bazı ölçülerde 2-4 kısa ötüş
            if rich and bar % 2 == 1 and rng.random() < 0.9:
                start = rng.choice([0.0, 1.25, 2.5, 3.0])
                for j in range(rng.randint(2, 4)):
                    f0 = rng.uniform(2300, 3600)
                    f1 = f0 * rng.choice([1.35, 1.5, 0.7])
                    chirp(m, b0 + start + j * 0.2, f0, f1, vol=0.07)
    # Başlangıçta kısa bir kuş selamı, finalde büyük kapanış
    for j, (f0, f1) in enumerate([(2400, 3600), (3000, 4300), (2600, 3900)]):
        chirp(m, 0.0 + j * 0.35, f0, f1, 0.11, 0.08)
    root, tones = chords["C"]
    for tn in tones:
        m.add(31 * 4 + 0.0, 3.6, tn + 12, "square", 0.07, duty=0.25, a=0.01, d=0.1, s=0.7, r=0.3)
    for j in range(5):
        chirp(m, 31 * 4 + 2.2 + j * 0.28, 2600 + 300 * j, 3600 + 350 * j, 0.1, 0.08)
    crash(m, 31 * 4, 0.16)
    out = m.render()
    return np.tanh(out * 2.3) / np.tanh(2.3) * 0.8   # tepeleri sıkıştır: ses öbür parçalarla aynı seviyede olsun


def write_ogg(name, samples):
    wav = os.path.join(OUT, name + ".wav")
    ogg = os.path.join(OUT, name + ".ogg")
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((samples * 32767).astype("<i2").tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "4", ogg], check=True)
    os.remove(wav)
    print(name, "%.1f s" % (len(samples) / SR), os.path.getsize(ogg) // 1024, "KB")


def main():
    os.makedirs(OUT, exist_ok=True)
    only = sys.argv[1] if len(sys.argv) > 1 else None   # örn: python make_music.py outro_theme
    _write = globals()["write_ogg"]

    def write_ogg(name, samples):
        if only is None or only == name:
            _write(name, samples)

    # Menü: neşeli majör, 112 bpm, kare dalga lead
    write_ogg("menu_theme", build("menu", 112, 60, MAJOR, PENT_MAJOR, [0, 4, 5, 3, 0, 4, 5, 3, 0, 4, 5, 3, 5, 3, 4, 0],
                                  "march", "root5", "eighth", ("square", 0.25, 0.0), seed=11))
    # Masa (sabah kararları): zıplayan, komik, yürüyen bas, 124 bpm
    write_ogg("desk_theme", build("desk", 124, 65, MAJOR, PENT_MAJOR, [0, 5, 3, 4, 0, 5, 1, 4, 0, 5, 3, 4, 3, 4, 0, 0],
                                  "bounce", "walk", "stab", ("square", 0.5, 0.0), seed=23, lead_vol=0.2))
    # Gazete: sallantılı gazete cıngılı, 126 bpm, testere dişi lead
    write_ogg("paper_theme", build("paper", 126, 62, MAJOR, MAJOR, [0, 3, 4, 0, 0, 3, 4, 0], "soft", "oompah", "stab",
                                   ("saw", 0.5, 1.0), bars=8, swing=0.45, seed=37, lead_vol=0.16))
    # Saha (bölüm 2-3): yürüyüş havasında, G majör, 104 bpm
    write_ogg("field_jaunty", build("jaunty", 104, 55, MAJOR, PENT_MAJOR, [0, 4, 5, 2, 3, 0, 4, 0, 0, 4, 5, 2, 3, 4, 0, 0],
                                    "soft", "root5", "eighth", ("tri", 0.5, 1.0), seed=41, lead_vol=0.3))
    # Saha (bölüm 4-6): gergin, la minör, 128 bpm
    write_ogg("field_tense", build("tense", 128, 57, MINOR, PENT_MINOR, [0, 0, 5, 6, 0, 0, 3, 4, 0, 0, 5, 6, 3, 4, 0, 0],
                                   "drive", "drive", "sixteenth", ("square", 0.125, 0.0), seed=53, lead_vol=0.17))
    # Intro: karamsar ve dramatik, re minör, 58 bpm
    write_ogg("intro_theme", build_dark())
    # Outro: cıvıl cıvıl, neşeli (ukulele, çan, ıslık, kuş cıvıltısı), do majör, 126 bpm
    write_ogg("outro_theme", build_joy())
    # Kaybedince: yavaş, hüzünlü ama sevimli, sol minör, 56 bpm
    write_ogg("gameover_theme", build("gameover", 56, 55, MINOR, PENT_MINOR, [0, 5, 3, 4, 0, 5, 3, 0],
                                      "none", "root5", "pad", ("tri", 0.5, 1.0), bars=8, seed=81, lead_vol=0.3))


if __name__ == "__main__":
    main()
