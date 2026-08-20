"""Pull the free CC0 pieces into the project.

Sources, all CC0 by Kenney (kenney.nl), taken from public GitHub mirrors:
  UI Pack            https://github.com/ereborstudios/kenney-ui-pack
  Platformer Art: Buildings, Boardgame Pack, Interface Sounds, Font Package
                     https://github.com/ETdoFresh/kenney.nl

The bingo hall does not exist as a single sprite anywhere, so it is built here out
of the 70x70 building tiles and saved as one PNG.
"""
import os
import shutil
from PIL import Image, ImageDraw, ImageFont

UI = "/home/claude/kui"
MIRROR = "/home/claude/kmirror"
PROJ = "/home/claude/GrandmaBingo"
ART = os.path.join(PROJ, "art", "ui")
AUDIO = os.path.join(PROJ, "audio")
FONTS = os.path.join(PROJ, "fonts")
for d in (ART, AUDIO, FONTS):
    os.makedirs(d, exist_ok=True)

TILES = os.path.join(MIRROR, "platformergraphics-buildings", "Tiles")


def tile(name):
    return Image.open(os.path.join(TILES, name + ".png")).convert("RGBA")


# ---- build the bingo hall out of tiles ---------------------------------
T = 70
COLS, ROWS = 5, 5
hall = Image.new("RGBA", (COLS * T, ROWS * T), (0, 0, 0, 0))


def put(name, col, row):
    hall.alpha_composite(tile(name), (col * T, row * T))


# roof: the Left and Right tiles are thin sloped slivers that leave gaps at this
# size, so the roof is built from the mid tiles alone, stepped in at the top
for c in range(1, 4):
    put("roofRedTopMid", c, 0)
for c in range(0, 5):
    put("roofRedMid", c, 1)

# walls
put("houseBeigeTopLeft", 0, 2)
for c in range(1, 4):
    put("houseBeigeTopMid", c, 2)
put("houseBeigeTopRight", 4, 2)
put("houseBeigeMidLeft", 0, 3)
for c in range(1, 4):
    put("houseBeige", c, 3)
put("houseBeigeMidRight", 4, 3)
put("houseBeigeBottomLeft", 0, 4)
for c in range(1, 4):
    put("houseBeigeBottomMid", c, 4)
put("houseBeigeBottomRight", 4, 4)

# windows, door and awnings
put("window", 1, 3)
put("window", 3, 3)
put("doorWindowTop", 2, 3)
put("doorKnob", 2, 4)
put("awningRed", 1, 4)
put("awningRed", 3, 4)

# ---- signboard over the door ------------------------------------------
sign = Image.open(os.path.join(UI, "sprites", "yellow_panel.png")).convert("RGBA")
SW, SH = 250, 72
# nine slice the panel up to the sign size so the corners stay round
m = 22
out = Image.new("RGBA", (SW, SH), (0, 0, 0, 0))
w, h = sign.size
parts = {
    "tl": (0, 0, m, m), "tm": (m, 0, w - m, m), "tr": (w - m, 0, w, m),
    "ml": (0, m, m, h - m), "mm": (m, m, w - m, h - m), "mr": (w - m, m, w, h - m),
    "bl": (0, h - m, m, h), "bm": (m, h - m, w - m, h), "br": (w - m, h - m, w, h),
}
crop = {k: sign.crop(v) for k, v in parts.items()}
out.alpha_composite(crop["tl"], (0, 0))
out.alpha_composite(crop["tr"], (SW - m, 0))
out.alpha_composite(crop["bl"], (0, SH - m))
out.alpha_composite(crop["br"], (SW - m, SH - m))
out.alpha_composite(crop["tm"].resize((SW - 2 * m, m)), (m, 0))
out.alpha_composite(crop["bm"].resize((SW - 2 * m, m)), (m, SH - m))
out.alpha_composite(crop["ml"].resize((m, SH - 2 * m)), (0, m))
out.alpha_composite(crop["mr"].resize((m, SH - 2 * m)), (SW - m, m))
out.alpha_composite(crop["mm"].resize((SW - 2 * m, SH - 2 * m)), (m, m))

font_path = os.path.join(MIRROR, "kenney_fontpackage", "Fonts", "Kenney Future.ttf")
f = ImageFont.truetype(font_path, 30)
d = ImageDraw.Draw(out)
tw = d.textlength("BINGO", font=f)
d.text(((SW - tw) / 2, SH / 2 - 20), "BINGO", font=f, fill=(60, 45, 20, 255))

hall_full = hall.copy()
hall_full.alpha_composite(out, ((COLS * T - SW) // 2, 2 * T - 6))
# superseded by the hand drawn hall in the TINA_GRANDMA repo, kept for reference
hall_full.save(os.path.join(PROJ, "art", "hall_tiles.png"))
print("hall_tiles.png", hall_full.size)

# ---- UI sprites --------------------------------------------------------
UI_COPY = {
    "grey_panel.png": "panel_grey.png",
    "blue_panel.png": "panel_blue.png",
    "green_panel.png": "panel_green.png",
    "red_panel.png": "panel_red.png",
    "yellow_panel.png": "panel_yellow.png",
    "grey_button00.png": "button_grey.png",
    "green_button00.png": "button_green.png",
    "green_boxTick.png": "box_tick.png",
    "grey_box.png": "box_empty.png",
}
for src, dst in UI_COPY.items():
    shutil.copy(os.path.join(UI, "sprites", src), os.path.join(ART, dst))
    print("ui/" + dst)

CHIPS = os.path.join(MIRROR, "boardgamepack", "PNG", "Chips")
for src, dst in {"chipWhite.png": "ball.png", "chipRedWhite.png": "chip_red.png",
                 "chipBlueWhite.png": "chip_blue.png"}.items():
    shutil.copy(os.path.join(CHIPS, src), os.path.join(ART, dst))
    print("ui/" + dst)

# ---- font --------------------------------------------------------------
shutil.copy(font_path, os.path.join(FONTS, "KenneyFuture.ttf"))
shutil.copy(os.path.join(MIRROR, "kenney_fontpackage", "Fonts", "Kenney Future Narrow.ttf"),
            os.path.join(FONTS, "KenneyFutureNarrow.ttf"))
print("fonts")

# ---- sound -------------------------------------------------------------
SFX = {
    "click": ("kenney_interfacesounds/Audio", "select_002.ogg"),
    "catch": ("kenney_interfacesounds/Audio", "drop_002.ogg"),
    "error": ("kenney_interfacesounds/Audio", "error_004.ogg"),
    "good": ("kenney_interfacesounds/Audio", "confirmation_001.ogg"),
    "pour": ("kenney_interfacesounds/Audio", "glass_002.ogg"),
    "swat": ("kenney_interfacesounds/Audio", "close_002.ogg"),
    "call": ("kenney_interfacesounds/Audio", "bong_001.ogg"),
    "mark": ("boardgamepack/Bonus", "chipsCollide1.ogg"),
    "win": ("boardgamepack/Bonus", "cardPlace1.ogg"),
}
for name, (folder, fn) in SFX.items():
    shutil.copy(os.path.join(MIRROR, folder, fn), os.path.join(AUDIO, name + ".ogg"))
    print("audio/" + name + ".ogg")

print("done")
