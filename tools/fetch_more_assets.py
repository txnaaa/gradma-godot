"""Third asset pass.

  - start page and basket from the TINA_GRANDMA repo
  - salt and ice icons drawn here as stand-ins (no CC0 one matched the style)
  - Chewy and Luckiest Guy from github.com/google/fonts
  - a smack for the fly swatter from Kenney's Impact Sounds
  - a gunshot and a background music loop synthesised from scratch
"""
import os
import shutil
import subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

REPO = "/home/claude/tina3"
MIRROR = "/home/claude/kmirror"
GFONTS = "/home/claude/gfonts"
PROJ = "/home/claude/GrandmaBingo"
ART = os.path.join(PROJ, "art")
AUDIO = os.path.join(PROJ, "audio")
FONTS = os.path.join(PROJ, "fonts")
SR = 44100

START_SRC = os.path.join(REPO, "WhatsApp Image 2026-08-19 at 11.28.18.jpeg")
BASKET_SRC = os.path.join(REPO, "WhatsApp Image 2026-08-19 at 11.34.20.jpeg")


def save(img, name, folder=ART):
    img.save(os.path.join(folder, name))
    print("%-20s %sx%s" % (name, img.width, img.height))


def cover(img, w, h):
    s = max(w / img.width, h / img.height)
    r = img.resize((round(img.width * s), round(img.height * s)), Image.LANCZOS)
    return r.crop(((r.width - w) // 2, (r.height - h) // 2,
                   (r.width - w) // 2 + w, (r.height - h) // 2 + h))


def cutout(img, tol=30, grow=2):
    arr = np.asarray(img.convert("RGB")).astype(np.int16)
    bg = arr.min(axis=2) > 255 - tol
    lab, _ = ndimage.label(bg)
    border = set(lab[0, :]) | set(lab[-1, :]) | set(lab[:, 0]) | set(lab[:, -1])
    border.discard(0)
    mask = np.isin(lab, list(border))
    if grow:
        mask = ndimage.binary_dilation(mask, iterations=grow)
    alpha = ndimage.gaussian_filter(np.where(mask, 0, 255).astype(np.uint8), 0.8)
    out = img.convert("RGBA")
    out.putalpha(Image.fromarray(alpha))
    return out


def trim(img, pad=4):
    box = img.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    if box is None:
        return img
    x0, y0, x1, y1 = box
    return img.crop((max(0, x0 - pad), max(0, y0 - pad),
                     min(img.width, x1 + pad), min(img.height, y1 + pad)))


def fit_h(img, h):
    return img.resize((max(1, round(img.width * h / img.height)), h), Image.LANCZOS)


# ---- start page and where its PLAY button sits -------------------------
start = Image.open(START_SRC).convert("RGB")
save(cover(start, 1280, 720), "bg_start.png")

a = np.asarray(cover(start, 1280, 720)).astype(int)
warm = (a[:, :, 0] > 150) & (a[:, :, 1] < 145) & (a[:, :, 2] < 140)
warm[:400, :] = False
lab, n = ndimage.label(warm)
sizes = ndimage.sum(warm, lab, range(1, n + 1))
ys, xs = np.nonzero(lab == int(np.argmax(sizes)) + 1)
print("PLAY button rect in the 1280x720 image: x %d-%d  y %d-%d"
      % (xs.min(), xs.max(), ys.min(), ys.max()))

# ---- basket -----------------------------------------------------------
save(fit_h(trim(cutout(Image.open(BASKET_SRC))), 190), "basket.png")


# ---- salt and ice, drawn here as stand-ins ----------------------------
def wobble(pts, amp=2.2, seed=0):
    rng = np.random.default_rng(seed)
    return [(x + rng.normal(0, amp), y + rng.normal(0, amp)) for x, y in pts]


def rounded_pts(x0, y0, x1, y1, r, steps=6):
    pts = []
    for cx, cy, a0 in [(x1 - r, y0 + r, -90), (x1 - r, y1 - r, 0),
                       (x0 + r, y1 - r, 90), (x0 + r, y0 + r, 180)]:
        for i in range(steps + 1):
            ang = np.radians(a0 + 90 * i / steps)
            pts.append((cx + r * np.cos(ang), cy + r * np.sin(ang)))
    return pts


def inked(size, draw_fn, seed=1):
    """Draw at 4x with a wobbly dark outline, then shrink for soft edges."""
    S = size * 4
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_fn(d, S, seed)
    return img.resize((size, size), Image.LANCZOS)


def draw_salt(d, S, seed):
    ink = (62, 44, 30, 255)
    u = S / 256.0
    body = rounded_pts(78 * u, 96 * u, 178 * u, 232 * u, 26 * u)
    d.polygon(wobble(body, 3 * u, seed), fill=(250, 248, 242, 255), outline=ink, width=int(7 * u))
    cap = [(84 * u, 96 * u), (172 * u, 96 * u), (162 * u, 48 * u), (94 * u, 48 * u)]
    d.polygon(wobble(cap, 2.5 * u, seed + 1), fill=(196, 158, 96, 255), outline=ink, width=int(7 * u))
    for cx, cy in [(112, 70), (128, 62), (144, 70), (120, 82), (136, 82)]:
        d.ellipse([(cx - 5) * u, (cy - 5) * u, (cx + 5) * u, (cy + 5) * u], fill=ink)
    d.line([(92 * u, 150 * u), (100 * u, 200 * u)], fill=(216, 212, 204, 255), width=int(6 * u))
    for cx, cy, r in [(196, 120, 7), (210, 148, 5), (192, 172, 6), (214, 196, 4)]:
        d.ellipse([(cx - r) * u, (cy - r) * u, (cx + r) * u, (cy + r) * u],
                  fill=(255, 255, 255, 255), outline=ink, width=int(3 * u))


def draw_ice(d, S, seed):
    ink = (44, 74, 92, 255)
    u = S / 256.0
    front = rounded_pts(60 * u, 96 * u, 196 * u, 216 * u, 20 * u)
    d.polygon(wobble(front, 3 * u, seed), fill=(178, 224, 244, 255), outline=ink, width=int(7 * u))
    top = [(60 * u, 106 * u), (104 * u, 48 * u), (238 * u, 48 * u), (196 * u, 106 * u)]
    d.polygon(wobble(top, 2.5 * u, seed + 2), fill=(226, 246, 253, 255), outline=ink, width=int(7 * u))
    side = [(196 * u, 106 * u), (238 * u, 48 * u), (238 * u, 160 * u), (196 * u, 216 * u)]
    d.polygon(wobble(side, 2.5 * u, seed + 3), fill=(146, 202, 228, 255), outline=ink, width=int(7 * u))
    d.line([(88 * u, 130 * u), (88 * u, 186 * u)], fill=(255, 255, 255, 235), width=int(13 * u))
    d.line([(112 * u, 138 * u), (112 * u, 166 * u)], fill=(255, 255, 255, 200), width=int(8 * u))


save(inked(220, draw_salt, 3), "salt.png")
save(inked(220, draw_ice, 7), "ice.png")

# ---- fonts -------------------------------------------------------------
shutil.copy(os.path.join(GFONTS, "apache/chewy/Chewy-Regular.ttf"), os.path.join(FONTS, "Chewy.ttf"))
shutil.copy(os.path.join(GFONTS, "apache/luckiestguy/LuckiestGuy-Regular.ttf"), os.path.join(FONTS, "LuckiestGuy.ttf"))
shutil.copy(os.path.join(GFONTS, "apache/chewy/LICENSE.txt"), os.path.join(FONTS, "LICENSE-Chewy.txt"))
shutil.copy(os.path.join(GFONTS, "apache/luckiestguy/LICENSE.txt"), os.path.join(FONTS, "LICENSE-LuckiestGuy.txt"))
print("fonts copied")

# ---- a proper smack for the swatter ------------------------------------
shutil.copy(os.path.join(MIRROR, "kenney_impactsounds/Audio/impactPunch_heavy_001.ogg"),
            os.path.join(AUDIO, "swat.ogg"))
print("audio/swat.ogg")


# ---- synthesised gunshot and music -------------------------------------
def write_ogg(samples, name, quality="5"):
    x = samples / max(1e-6, np.abs(samples).max()) * 0.86
    raw = (x * 32767).astype("<i2").tobytes()
    wav = "/tmp/%s.wav" % name
    with open(wav, "wb") as f:
        n = len(raw)
        f.write(b"RIFF" + (36 + n).to_bytes(4, "little") + b"WAVEfmt ")
        f.write((16).to_bytes(4, "little") + (1).to_bytes(2, "little") + (1).to_bytes(2, "little"))
        f.write(SR.to_bytes(4, "little") + (SR * 2).to_bytes(4, "little"))
        f.write((2).to_bytes(2, "little") + (16).to_bytes(2, "little"))
        f.write(b"data" + n.to_bytes(4, "little") + raw)
    out = os.path.join(AUDIO, name + ".ogg")
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", wav,
                    "-c:a", "libvorbis", "-q:a", quality, out], check=True)
    print("audio/%s.ogg  %.1fs" % (name, len(samples) / SR))


rng = np.random.default_rng(11)
t = np.arange(int(0.55 * SR)) / SR
crack = rng.normal(0, 1, t.size) * np.exp(-t * 42.0)
body = np.sin(2 * np.pi * (150 * np.exp(-t * 9.0) + 45) * t) * np.exp(-t * 13.0)
tail = rng.normal(0, 1, t.size) * np.exp(-t * 5.5) * 0.22
write_ogg(crack * 0.85 + body * 0.9 + tail, "gunshot", "6")


def adsr(n, a=0.01, d=0.35, s=0.0):
    e = np.exp(-np.arange(n) / SR / d)
    atk = int(a * SR)
    if atk > 0:
        e[:atk] *= np.linspace(0, 1, atk)
    return e * (1 - s) + s * (np.arange(n) < n)


def note(freq, dur, kind="pluck", amp=1.0):
    n = int(dur * SR)
    x = np.arange(n) / SR
    if kind == "bass":
        w = np.sin(2 * np.pi * freq * x) + 0.35 * np.sin(4 * np.pi * freq * x)
        return w * adsr(n, 0.006, 0.24) * amp
    if kind == "stab":
        w = np.sign(np.sin(2 * np.pi * freq * x)) * 0.35 + np.sin(2 * np.pi * freq * x)
        return w * adsr(n, 0.012, 0.13) * amp
    w = (np.sin(2 * np.pi * freq * x) + 0.5 * np.sin(4 * np.pi * freq * x)
         + 0.22 * np.sin(6 * np.pi * freq * x))
    return w * adsr(n, 0.01, 0.30) * amp


def hz(semi):
    return 440.0 * 2 ** ((semi - 9) / 12.0)


BPM = 112.0
BEAT = 60.0 / BPM
BARS = 8
track = np.zeros(int(BARS * 4 * BEAT * SR) + SR // 2)


def place(sig, beat):
    i = int(beat * BEAT * SR)
    track[i:i + sig.size] += sig[:max(0, track.size - i)]


# F  Dm  Bb  C, two bars each
CHORDS = [[5, 9, 12], [2, 5, 9], [10, 14, 17], [0, 4, 7]]
BASSES = [5, 2, 10, 0]
MELODY = [12, 14, 17, 14, 12, 9, 12, None, 14, 17, 19, 17, 14, 12, 9, None]

for bar in range(BARS):
    c = CHORDS[(bar // 2) % 4]
    root = BASSES[(bar // 2) % 4]
    b0 = bar * 4
    for beat in [0, 2]:
        place(note(hz(root - 12), BEAT * 0.9, "bass", 0.55), b0 + beat)
    for beat in [1, 3]:
        for s in c:
            place(note(hz(s), BEAT * 0.45, "stab", 0.13), b0 + beat)
    for i in range(8):
        place(rng.normal(0, 1, int(0.05 * SR)) * np.exp(-np.arange(int(0.05 * SR)) / SR / 0.02) * 0.035,
              b0 + i * 0.5)
    for i in range(2):
        m = MELODY[(bar * 2 + i) % len(MELODY)]
        if m is not None:
            place(note(hz(m), BEAT * 1.6, "lead", 0.30), b0 + i * 2 + 0.5)

loop = track[:int(BARS * 4 * BEAT * SR)].copy()
tailover = track[int(BARS * 4 * BEAT * SR):]
loop[:tailover.size] += tailover  # wrap the ring-out so the loop joins cleanly
write_ogg(loop, "music", "5")

print("done")
