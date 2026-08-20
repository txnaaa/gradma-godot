"""Turn the WhatsApp JPEGs into game ready PNGs with transparency."""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

SRC = "/home/claude/tina2"
OUT = "/home/claude/GrandmaBingo/art"
os.makedirs(OUT, exist_ok=True)

F = {}
for line in open("/home/claude/filelist.txt"):
    i, name = line.strip().split("|", 1)
    F[int(i)] = os.path.join(SRC, name)


def cutout(img, dark_bg=False, tol=28, grow=2):
    """Remove the border connected background, keep interior whites."""
    arr = np.asarray(img.convert("RGB")).astype(np.int16)
    if dark_bg:
        bgish = arr.max(axis=2) < tol + 20
    else:
        bgish = arr.min(axis=2) > 255 - tol
    lab, n = ndimage.label(bgish)
    border = set(lab[0, :]) | set(lab[-1, :]) | set(lab[:, 0]) | set(lab[:, -1])
    border.discard(0)
    bg = np.isin(lab, list(border))
    if grow > 0:
        bg = ndimage.binary_dilation(bg, iterations=grow)
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    alpha = ndimage.gaussian_filter(alpha, 0.8)
    out = img.convert("RGBA")
    out.putalpha(Image.fromarray(alpha))
    return out


def trim(img, pad=4):
    bbox = img.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    if bbox is None:
        return img
    x0, y0, x1, y1 = bbox
    return img.crop((max(0, x0 - pad), max(0, y0 - pad),
                     min(img.width, x1 + pad), min(img.height, y1 + pad)))


def fit_h(img, h):
    return img.resize((max(1, round(img.width * h / img.height)), h), Image.LANCZOS)


def cover(img, w, h):
    s = max(w / img.width, h / img.height)
    r = img.resize((round(img.width * s), round(img.height * s)), Image.LANCZOS)
    x = (r.width - w) // 2
    y = (r.height - h) // 2
    return r.crop((x, y, x + w, y + h))


def save(img, name):
    img.save(os.path.join(OUT, name))
    print("%-22s %sx%s" % (name, img.width, img.height))


# ---- full screen backgrounds -------------------------------------------
for idx, name in [(8, "bg_market.png"), (11, "bg_lemons.png"), (13, "bg_bar.png"),
                  (28, "bg_bingo.png"), (29, "bg_win.png"), (2, "bg_end.png")]:
    save(cover(Image.open(F[idx]).convert("RGB"), 1280, 720), name)

# ---- stalls, cut out and trimmed ---------------------------------------
save(fit_h(trim(cutout(Image.open(F[4]))), 330), "tent_fruit.png")
save(fit_h(trim(cutout(Image.open(F[5]))), 330), "tent_drinks.png")
save(fit_h(trim(cutout(Image.open(F[0]))), 330), "stall_fruit_plain.png")
ice = Image.open(F[10])
save(fit_h(trim(cutout(ice.crop((0, 0, int(ice.width * 0.60), ice.height)))), 330), "tent_chilli.png")

# ---- characters and props ----------------------------------------------
save(fit_h(trim(cutout(Image.open(F[3]))), 230), "grandma.png")
save(fit_h(trim(cutout(Image.open(F[7]))), 90), "fly1.png")
save(fit_h(trim(cutout(Image.open(F[9]))), 90), "fly2.png")
save(fit_h(trim(cutout(Image.open(F[1]), dark_bg=True)), 90), "fly3.png")
save(fit_h(trim(cutout(Image.open(F[6]))), 300), "swatter.png")

for n, idx in enumerate([22, 25, 26, 27]):
    save(fit_h(trim(cutout(Image.open(F[idx]))), 86), "chilli_red%d.png" % (n + 1))
for n, idx in enumerate([23, 24]):
    save(fit_h(trim(cutout(Image.open(F[idx]))), 78), "chilli_green%d.png" % (n + 1))

# ---- glass and liquid share one canvas ---------------------
GLASS = 520
save(cutout(Image.open(F[20]), tol=18, grow=1).resize((GLASS, GLASS), Image.LANCZOS), "glass.png")
for n, idx in enumerate([14, 15, 16, 17, 18, 19]):
    save(cutout(Image.open(F[idx])).resize((GLASS, GLASS), Image.LANCZOS), "fill%d.png" % n)

# ---- bottle pouring also share a canvas -----------------------
POUR_W = 620
for idx, name in [(12, "bottle_idle.png"), (21, "bottle_pour.png")]:
    im = cutout(Image.open(F[idx]))
    save(im.resize((POUR_W, round(im.height * POUR_W / im.width)), Image.LANCZOS), name)

print("done")

# Each drawing is a separate blob of ink on white, so label them and cut by box.
SHEET = os.path.join(SRC, "WhatsApp Image 2026-08-17 at 15.55.19.jpeg")

SHEET_PARTS = [
    # (x0, x1, y0, y1, output name, height in game pixels)
    (99, 568, 1100, 1647, "grandma_walk.png", 300),
    (684, 1111, 1123, 1643, "grandma_angry.png", 300),
    (896, 1285, 154, 464, "icon_retry.png", 150),
    (201, 615, 814, 999, "btn_play.png", 110),
    (880, 1146, 588, 832, "cookie.png", 120),
    (1191, 1308, 1648, 1785, "anger.png", 100),
]

if os.path.exists(SHEET):
    sheet = cutout(Image.open(SHEET), tol=34, grow=2)
    for x0, x1, y0, y1, name, h in SHEET_PARTS:
        part = sheet.crop((x0 - 8, y0 - 8, x1 + 8, y1 + 8))
        save(fit_h(trim(part), h), name)

old = os.path.join(OUT, "grandma.png")
if os.path.exists(old) and os.path.exists(os.path.join(OUT, "grandma_walk.png")):
    os.replace(old, os.path.join(OUT, "vendor.png"))
    print("renamed grandma.png -> vendor.png")


# ---- ingredient icons for the cocktail game ----------------------------
# One lemon cut out of the crate drawing, and the bottle without the hand.
def _drop_colour(img, sample, tol=52, grow=1):
    """Make the border connected pixels near `sample` transparent."""
    arr = np.asarray(img.convert("RGB")).astype(int)
    dist = np.sqrt(((arr - np.array(sample)) ** 2).sum(axis=2))
    bgish = dist < tol
    lab, n = ndimage.label(bgish)
    border = set(lab[0, :]) | set(lab[-1, :]) | set(lab[:, 0]) | set(lab[:, -1])
    border.discard(0)
    bg = np.isin(lab, list(border))
    if grow:
        bg = ndimage.binary_dilation(bg, iterations=grow)
    alpha = ndimage.gaussian_filter(np.where(bg, 0, 255).astype(np.uint8), 0.7)
    out = img.convert("RGBA")
    out.putalpha(Image.fromarray(alpha))
    return out


crate = Image.open(os.path.join(OUT, "bg_lemons.png")).convert("RGB")
lemon = crate.crop((342, 298, 542, 482)).convert("RGBA")
lw, lh = lemon.size
mask = Image.new("L", (lw * 4, lh * 4), 0)
ImageDraw.Draw(mask).ellipse((10, 24, lw * 4 - 10, lh * 4 - 24), fill=255)
mask = mask.resize((lw, lh), Image.LANCZOS).filter(ImageFilter.GaussianBlur(1.6))
lemon.putalpha(mask)
save(fit_h(trim(lemon), 96), "lemon.png")

bottle = Image.open(os.path.join(OUT, "bottle_idle.png")).convert("RGBA")
save(fit_h(trim(bottle.crop((0, 0, 412, bottle.height))), 96), "bottle_icon.png")
