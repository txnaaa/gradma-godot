"""Two synthesised music loops: a driving rock track and a villain lair drone.

Both are placeholders in the same sense as before, made here rather than licensed,
so they can be swapped for real tracks by overwriting the .ogg files.
"""
import os
import subprocess
import numpy as np

AUDIO = "/home/claude/GrandmaBingo/audio"
SR = 44100
rng = np.random.default_rng(7)


def write_ogg(sig, name, q="5"):
    x = sig / max(1e-9, np.abs(sig).max()) * 0.88
    raw = (x * 32767).astype("<i2").tobytes()
    wav = "/tmp/%s.wav" % name
    with open(wav, "wb") as f:
        n = len(raw)
        f.write(b"RIFF" + (36 + n).to_bytes(4, "little") + b"WAVEfmt ")
        f.write((16).to_bytes(4, "little") + (1).to_bytes(2, "little") + (1).to_bytes(2, "little"))
        f.write(SR.to_bytes(4, "little") + (SR * 2).to_bytes(4, "little"))
        f.write((2).to_bytes(2, "little") + (16).to_bytes(2, "little"))
        f.write(b"data" + n.to_bytes(4, "little") + raw)
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", wav,
                    "-c:a", "libvorbis", "-q:a", q, os.path.join(AUDIO, name + ".ogg")], check=True)
    print("%s.ogg  %.1fs" % (name, len(sig) / SR))


def hz(semi):
    return 440.0 * 2 ** ((semi - 9) / 12.0)


def saw(freq, n, detune=0.0):
    x = np.arange(n) / SR
    out = np.zeros(n)
    for h in range(1, 11):
        out += np.sin(2 * np.pi * freq * (1 + detune) * h * x) / h
    return out


def env(n, a, d):
    e = np.exp(-np.arange(n) / SR / d)
    k = max(1, int(a * SR))
    e[:k] *= np.linspace(0, 1, k)
    return e


def kick(n):
    x = np.arange(n) / SR
    f = 118 * np.exp(-x * 26) + 46
    return np.sin(2 * np.pi * f * x) * np.exp(-x * 15) * 1.1


def snare(n):
    x = np.arange(n) / SR
    body = np.sin(2 * np.pi * 190 * x) * np.exp(-x * 26) * 0.5
    nz = rng.normal(0, 1, n) * np.exp(-x * 21)
    return body + nz * 0.85


def hat(n, decay=42.0):
    x = np.arange(n) / SR
    h = rng.normal(0, 1, n) * np.exp(-x * decay)
    return np.diff(h, prepend=0.0) * 0.5


# ---------------------------------------------------------------- rock
BPM = 152.0
BEAT = 60.0 / BPM
BARS = 8
rock = np.zeros(int(BARS * 4 * BEAT * SR) + SR)


def put(track, sig, beat, beat_len=BEAT):
    i = int(beat * beat_len * SR)
    end = min(track.size, i + sig.size)
    track[i:end] += sig[:end - i]


def power_chord(root, dur, amp=1.0):
    n = int(dur * SR)
    raw = saw(hz(root), n) + saw(hz(root + 7), n, 0.002) + saw(hz(root - 12), n, -0.001) * 0.8
    driven = np.tanh(raw * 3.4)
    return driven * env(n, 0.004, dur * 0.85) * amp


PROG = [4, 4, 7, 9, 4, 4, 2, 7]
RIFF = [16, 19, 21, 19, 16, 14, 16, None, 21, 19, 16, 19, 14, 16, 12, None]

for bar in range(BARS):
    b0 = bar * 4
    root = PROG[bar % len(PROG)]
    for beat, dur in [(0, 0.75), (0.75, 0.25), (1.5, 0.5), (2, 0.75), (2.75, 0.25), (3.5, 0.5)]:
        put(rock, power_chord(root - 12, BEAT * dur * 1.05, 0.30), b0 + beat)
    for beat in [0, 1.5, 2, 3.5]:
        put(rock, kick(int(0.22 * SR)) * 0.85, b0 + beat)
    for beat in [1, 3]:
        put(rock, snare(int(0.20 * SR)) * 0.55, b0 + beat)
    for i in range(8):
        put(rock, hat(int(0.07 * SR)) * (0.30 if i % 2 == 0 else 0.18), b0 + i * 0.5)
    if bar % 2 == 1:
        for i in range(4):
            m = RIFF[(bar * 4 + i) % len(RIFF)]
            if m is not None:
                n = int(BEAT * 0.9 * SR)
                lead = np.tanh(saw(hz(m), n) * 2.2) * env(n, 0.006, 0.22)
                put(rock, lead * 0.16, b0 + i)

loop_n = int(BARS * 4 * BEAT * SR)
out = rock[:loop_n].copy()
out[:rock.size - loop_n] += rock[loop_n:]
write_ogg(out, "music_rock")

# ------------------------------------------------------- villain lair(not gonna use that anymore)
LEN = 24.0
n = int(LEN * SR)
x = np.arange(n) / SR
lair = np.zeros(n)

lair += np.sin(2 * np.pi * hz(-20) * x) * 0.55
lair += np.sin(2 * np.pi * hz(-20) * 1.004 * x) * 0.45
lair += np.sin(2 * np.pi * hz(-8) * x) * 0.18 * (0.6 + 0.4 * np.sin(2 * np.pi * 0.07 * x))

# a slow minor arpeggio on a bell tone, E minor with a flat second for menace
ARP = [4, 7, 11, 15, 11, 7, 5, 7]
step = LEN / len(ARP)
for i, semi in enumerate(ARP):
    ln = int(step * 1.9 * SR)
    ln = min(ln, n)
    xx = np.arange(ln) / SR
    bell = (np.sin(2 * np.pi * hz(semi) * xx)
            + 0.4 * np.sin(2 * np.pi * hz(semi) * 2.01 * xx)
            + 0.2 * np.sin(2 * np.pi * hz(semi) * 3.02 * xx))
    bell *= env(ln, 0.02, 1.5) * 0.20
    s = int(i * step * SR)
    end = min(n, s + ln)
    lair[s:end] += bell[:end - s]


for beat in np.arange(0.0, LEN, 3.0):
    ln = int(0.5 * SR)
    xx = np.arange(ln) / SR
    tom = np.sin(2 * np.pi * (86 * np.exp(-xx * 9) + 38) * xx) * np.exp(-xx * 7) * 0.42
    s = int(beat * SR)
    end = min(n, s + ln)
    lair[s:end] += tom[:end - s]

for centre in [8.0, 19.0]:
    swell = np.exp(-((x - centre) ** 2) / 4.0)
    lair += rng.normal(0, 1, n) * swell * 0.05

s = int(20.5 * SR)
ln = min(int(2.4 * SR), n - s)
xx = np.arange(ln) / SR
stab = (np.sin(2 * np.pi * hz(4) * xx) + np.sin(2 * np.pi * hz(10) * xx)) * env(ln, 0.01, 0.9) * 0.28
lair[s:s + ln] += stab


fade = int(0.35 * SR)
lair[:fade] *= np.linspace(0, 1, fade)
lair[-fade:] *= np.linspace(1, 0, fade)
write_ogg(lair, "music_lair")

old = os.path.join(AUDIO, "music.ogg")
if os.path.exists(old):
    os.remove(old)
    print("removed the old music.ogg")
print("done")
