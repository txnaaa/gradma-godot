# Grandma's Bingo Night

A 2D Godot 4 game. Nan remembers she has bingo tonight, so she legs it round the market
tents to tick off her grocery list before the shutters come down, then plays out the
evening at the hall.

Your artwork from the TINA_GRANDMA repo is cut out, made transparent and wired into every
scene. Everything that used to be drawn with code rectangles (the hall, the bingo squares,
the timer bar, the labels) is now a real asset: free CC0 art from Kenney, plus sound and a
proper font. See CREDITS.md.

## Opening the project

1. Install Godot 4.3 or newer (standard version, not .NET). https://godotengine.org/download
2. Open Godot, click Import, and select the `project.godot` file in this folder.
3. Press F5. It starts on the main menu.

If Godot warns the project was made with a different version, click "Convert full project".

## The flow

MainMenu (your start page, click PLAY) -> intro video -> Intro cards -> Map

On the map, arrow keys walk Nan, space goes into whatever she is standing in front of,
and Tab opens the grocery checklist. Clicking a stall you can see still works and walks
her over to it. Where she is standing is kept in `Game.map_x`, so coming back from a
minigame puts her back at that stall rather than at the gate. -> (Chilli / Drinks / Flies in any order) -> Map -> BingoHall ->
Cocktails -> Bingo -> Ending

The shop timer only runs during the market half. It lives in `Game.shop_time_left`, so it
keeps counting across scene changes, which makes the three tents feel like one shopping
trip rather than three separate games. Mistakes cost seconds instead of ending the run.

## What is in the box

```
project.godot          settings, autoloads, 1280x720
art/                   your drawings, cut out and resized
art/ui/                Kenney CC0 panels, chips and boxes
art/hall.png           the bingo hall, built from Kenney building tiles
audio/                 Kenney CC0 sound effects
fonts/                 Kenney Future and Kenney Future Narrow
scenes/                one .tscn per scene, each just a root node with a script
scripts/
  Game.gd              autoload: shop timer, grocery list, score, scene changes
  Art.gd               loads and draws PNGs, nine slices panels, holds the font
  Sfx.gd               autoload: small pool of audio players, Sfx.play("click")
  Hud.gd               shared HUD built in code
  Map.gd               the market, walk between tents and click one to enter
  ChilliGame.gd        Nan follows the mouse, catch falling chillies in her arms
  DrinkGame.gd         hold to pour, stop when the drink reaches the line
  FlyGame.gd           swat fruit flies off the lemons with the racket
  CocktailGame.gd      mix drinks from the shopping: click chilli, lemon and shots
  BingoGame.gd         the card, called numbers, mark them before the next call
  Cutscene.gd          plays your intro video, skips itself if there is no file
  Intro / BingoHall    story cards
  Ending / ShopsClosed win and fail screens
tools/process_assets.py     turns your JPEGs into the PNGs in art/
tools/fetch_free_assets.py  copies in the CC0 assets and bakes art/hall.png
CREDITS.md                  what came from where, and the licences
```

## The free assets, and why each one is there

Nothing in the game is a coloured rectangle any more.

| Was drawn in code | Is now |
|---|---|
| Purple box labelled BINGO HALL | `art/hall.png`, built from Kenney's building tiles with a signboard baked on |
| Bingo card squares and backing | Kenney UI panels, nine sliced, with poker chips as the daubers |
| White disc over the telly | a white chip from the Boardgame Pack |
| Timer bar and its background | Kenney panels as NinePatchRects, green until the last quarter then red |
| Label backgrounds and plaques | Kenney panels, tinted dark so white text reads on them |
| Level readout at the drinks stand | Kenney panels, yellow for the level she asked for, red for what you have poured |
| Godot's default font | Kenney Future Narrow for UI, Kenney Future for the big numbers |
| Silence | Kenney interface and boardgame sounds on every catch, pour, swat, mistake and call |

The glass, the six fill levels and the pouring bottle are untouched, as you asked.

Nine slicing is the bit worth knowing about. A Kenney panel is 100x100 with rounded
corners, so stretching it to 520x40 would smear the corners. `Art.nine()` cuts it into
nine pieces and stretches only the middles, which is why the panels look right at any
size. The HUD uses Godot's built in `NinePatchRect` for the same reason.

## How your art got used

| Your drawing | Became | Used in |
|---|---|---|
| Landscape with hills | `bg_market.png` | menu, intro, map, chilli stand |
| Fruit stall with the girl | `tent_fruit.png` | map |
| Drink products stall | `tent_drinks.png` | map |
| Ice and Spice tent | `tent_chilli.png` | map, chilli stand |
| Start page with PLAY | `bg_start.png` | the first screen, the button is a hotspot over the painted one |
| Basket | `basket.png` | catches the chillies at the spice stand |
| Grandma, walking with her drink | `grandma_walk.png` | menu, intro, map, chilli stand, hall, win screen |
| Grandma, furious | `grandma_angry.png` | shops closed screen |
| PLAY bubble | `btn_play.png` | main menu, grows on hover |
| Flaming reload | `icon_retry.png` | both end screens, grows on hover |
| Biscuit | `cookie.png` | menu, last intro card, over a finished stall, win screen |
| Red anger mark | `anger.png` | pops up whenever you drop, spill or miss |
| Black haired woman | `vendor.png` | spare, she is the stall keeper not Nan |
| Three flies | `fly1/2/3.png` | fruit stand, cycled for a wing flap |
| Pink swatter | `swatter.png` | fruit stand cursor |
| Six chillies | `chilli_red1-4`, `chilli_green1-2` | falling chillies, picked at random |
| Crate of lemons | `bg_lemons.png` | fruit stand background |
| Bar with bottles | `bg_bar.png` | drinks stand, hall, cocktails |
| Empty glass | `glass.png` | drinks stand, cocktails |
| Six liquid levels | `fill0-5.png` | the fill levels |
| Hand with bottle, idle and pouring | `bottle_idle/pour.png` | drinks stand, cocktails |
| Bingo hall with the telly | `bg_bingo.png` | bingo game |
| Bingo hall with WIN | `bg_win.png` | winning ending |
| THE END | `bg_end.png` | losing ending |
| Plain fruit stall | `stall_fruit_plain.png` | spare, not used yet |

The second sheet you uploaded had six drawings on one page, so the script finds each blob
of ink and cuts them out separately. The black haired woman from the first drop is the
same person painted into the fruit stall, so she is the stall keeper, not Nan. She got
renamed to `vendor.png` and the new drawing took over as grandma.

The six liquid levels turned out to be the best thing in the folder. Because they are
discrete, the drink game is now "stop on level 4" rather than a vague bar, which is a much
clearer instruction and reads properly on screen. The glass and the six levels share one
square canvas, so they are drawn with the same centre and size (`Art.canvas_sprite`) and
the liquid lands inside the glass automatically. If you ever resize one, resize all seven.

## Tuning

| What | Where | Value |
|---|---|---|
| Total shopping time | `Game.gd`, `SHOP_TIME` | 150 s |
| How far apart the stalls are | `Map.gd`, `WORLD_W` and the `x` in `stalls` | 2800 wide world |
| How fast Nan walks | `Map.gd`, `walk_speed` | 320 |
| How close she must stand to enter | `Map.gd`, `REACH` | 190 px |
| Chillies needed | `ChilliGame.gd`, `TARGET` | 12 |
| Catch area on Nan | `ChilliGame.gd`, `CATCH_TOP`, `CATCH_W`, `CATCH_H` | chest height |
| Glasses to pour | `DrinkGame.gd`, `CUPS_NEEDED` | 3 |
| Pour speed | `DrinkGame.gd`, `_pour_rate()` | faster each glass |
| Where the line can land | `DrinkGame.gd`, `randi_range(2, LEVELS)` | levels 2 to 6 |
| Flies and racket size | `FlyGame.gd`, `FLY_COUNT`, `HIT_RADIUS` | 9, 62 px |
| Bingo call speed | `BingoGame.gd`, `CALL_INTERVAL` | 2.4 s |
| Orders at the hall | `CocktailGame.gd`, `ORDERS`, `ROUND_TIME` | 5 orders, 80 s |
| PLAY and retry buttons | `PLAY_CENTRE`, `RETRY_CENTRE`, and the `_H` next to them | position and size |

Change one number at a time or you will not know which one fixed it.

---

# Things I could not do, step by step

## 1. The intro video

Already done, and it now sits behind the PLAY button rather than firing on launch. Your video is converted and sitting at `video/intro.ogv`, and the game opens
on it. Click or Esc skips it, and it goes to the menu on its own when it finishes.

It had to be converted because Godot 4 plays Ogg Theora and nothing else, so an mp4 will
not load however you point at it. What ran was:

```
ffmpeg -i intro.mp4 -vf "scale=1280:720:flags=lanczos" \
       -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 -ar 44100 intro.ogv
```

27 seconds, scaled 1920x1080 down to 1280x720 to match the game window, audio kept. It
comes out at 17 MB, which is most of the project size. Dropping to `-q:v 5 -q:a 3` gives
9.5 MB and still looks fine, worth doing if you ever export to web.

To swap in a different cut, run that command on the new file and save it over
`video/intro.ogv`. To use a different filename, change `VIDEO_PATH` at the top of
`scripts/Cutscene.gd`. To skip the video while you are working on the game, set
`run/main_scene` in `project.godot` back to `res://scenes/MainMenu.tscn`.

One catch worth knowing: Godot does not stream the audio and video separately, so if the
video ever looks out of sync after a re-encode, add `-async 1` to the command.

## 2. Nudge the art positions

Every position is a constant at the top of a script, in a 1280x720 space with y going
down. I placed them by measuring your images, but you will see things I cannot.

- Bottle over the glass: `DrinkGame.gd`, `BOTTLE_TOPLEFT` and `BOTTLE_W`. Lower the y to
  bring the bottle down, raise x to move it right.
- Glass on the table: `GLASS_CENTRE` and `GLASS_SIZE`. Move both games together or the
  hall will not match.
- Tents on the map: the `x` values in the `stalls` array in `Map.gd`, and `GROUND_Y` for
  how high they sit on the grass.
- Bingo card: `ORIGIN`, `CELL_W`, `CELL_H` in `BingoGame.gd`. The white disc that covers
  the 67 painted on your telly is `BALL_CENTRE` and `BALL_R`, measured from the image.

Run the game, press F8 to stop, change one number, run again. Faster than guessing.

## 3. Swap out any of the free assets

The CC0 packs have far more than I used. Kenney's UI Pack alone has 430 files in five
colours, and the sound packs have hundreds of clips.

1. Browse the full packs at https://kenney.nl/assets, all CC0.
2. Drop a new PNG in `art/ui/` and call it by filename: `Art.nine(self, "panel_blue", rect)`
   or `Art.sprite(self, "chip_blue", pos, size)`. `Art.tex()` checks `art/` first, then
   `art/ui/`, so no path juggling.
3. For a new sound, drop the `.ogg` in `audio/` and call `Sfx.play("yourfile")`. The name
   is the filename without the extension.
4. To change the whole look, swap the panel colour in one place. Every bingo square is
   `panel_blue`, every label backing is `panel_grey` tinted dark.

There are two music tracks, `audio/music_rock.ogg` for the market and `audio/music_lair.ogg`
for the bingo hall, both synthesised by me in `tools/make_music.py` rather than licensed.
Replacing either is one file: convert any track to `.ogg` and save it over that name. Free CC0 sources worth a look are incompetech.com, the CC0 filter
on freesound.org, and opengameart.org. `Sfx.play_music("music_rock")` loops a track and only restarts it if a different one is
already going, so scene changes do not retrigger it. `Sfx.stop_music()` cuts it, which is
how the intro video plays without music underneath and how the losing ending goes silent
for the gunshot.

## 4. Add more art, or redo a cutout

Your JPEGs have white backgrounds, so I flood filled from the edges inwards. That keeps
white parts inside the drawing, like the fly wings and the glass, which a plain "delete
white" would have eaten.

To process new drawings:

1. Put the new JPEGs in a folder and edit the paths at the top of
   `tools/process_assets.py`.
2. Add a line for your image, copying the pattern:
   `save(fit_h(trim(cutout(Image.open(path))), 200), "my_thing.png")`
   where 200 is the height you want in game pixels.
3. Run `pip install pillow numpy scipy` then `python3 tools/process_assets.py`.
4. Drop the PNG in `art/` and call it with `Art.sprite(self, "my_thing", pos, height)`.

If a cutout leaves a white halo, raise `grow` in the `cutout` call from 2 to 3. If it eats
part of the drawing, lower `tol` from 28 to about 18.

## 5. The gaps left in your own art

I worked around these, but they are the obvious things to draw next.

- **No bingo hall exterior.** Filled with a Kenney building for now, so it does not match
  your hand drawn style. If you draw one, export it as `art/hall.png` at roughly the same
  proportions and nothing in the code needs to change.
- **No basket.** So Nan catches chillies in her arms instead. If you draw a basket, add it
  as a sprite at the catch rectangle and shrink `CATCH_H`.
- **No idle or happy pose.** The angry drawing only shows on the shops closed screen, and
  everywhere else a mistake just pops the red anger mark. A pleased Nan would be worth
  drawing for the win screen and for finishing a stall.
- **One walk frame.** Nan has legs now, but only one pose, so on the map she slides along
  with a small bob. Two more frames would fix it.

For a walk cycle, export `grandma_walk2.png` and `grandma_walk3.png` at the same size,
then in `Map.gd`:
```
var frame: String = "grandma_walk"
if walking:
    frame = ["grandma_walk", "grandma_walk2", "grandma_walk3"][int(bob) % 3]
Art.sprite_bottom(self, frame, Vector2(grandma_x, GROUND_Y - lift), GRANDMA_H, facing_right)
```
Her drawing faces left, so `flip` is `facing_right` rather than `not facing_right`. Keep
that the same way round in any new frame or she will moonwalk.

## 6. More sound, and music

Nine sound effects are already wired up through the `Sfx` autoload. What is missing is
music and a voice.

1. For background music, add an `AudioStreamPlayer` node to a scene, drag in a track,
   click the file in the FileSystem dock, Import tab, tick Loop, Reimport, then tick
   Autoplay on the node.
2. Set up buses so music can be muted separately from effects: Audio tab at the bottom of
   the editor, add a bus called `Music`, set the player's Bus to it.
3. The bingo caller is the obvious thing to voice. Recording your nan reading numbers out
   would be worth more than any amount of code. Drop the clips in `audio/` as `num1.ogg`
   through `num75.ogg` and call `Sfx.play("num" + str(called_number))` next to the
   existing `Sfx.play("call")` in `BingoGame.gd`.

## 7. Saving a high score

In `Game.gd`:
```
const SAVE_PATH := "user://save.cfg"
var best_score: int = 0

func load_best() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) == OK:
        best_score = cfg.get_value("progress", "best", 0)

func save_best() -> void:
    if total_score() > best_score:
        best_score = total_score()
    var cfg := ConfigFile.new()
    cfg.set_value("progress", "best", best_score)
    cfg.save(SAVE_PATH)
```
Call `load_best()` from `Game._ready()` and `save_best()` from `Ending._ready()`.

## 8. Exporting

1. Editor menu, Manage Export Templates, Download and Install. One off.
2. Project menu, Export, Add, pick Windows Desktop or Web.
3. Web builds do not open by double clicking. Upload the folder to itch.io as an HTML5
   game with "played in the browser" ticked, or run `python3 -m http.server` in the folder
   and open localhost:8000.

## 9. Version control

The art repo is already on GitHub. Put the game there too.

1. `git init` in this folder.
2. `.gitignore` is already here with `.godot/` and `export_presets.cfg` in it.
3. Commit after each working feature, not at the end of the day. "chilli speed now scales
   with catches" beats "updates".

## 10. What to watch when someone plays it

- Do they understand the timer is global rather than per minigame?
- Does the dashed line read as "fill to here" without being told?
- Does anyone open the grocery checklist without being prompted, or does it need to start open?
- Is 2.4 seconds enough to find a number on a card they have not memorised?
- Do they try to click a tent before Nan has walked over, and does the delay annoy them?
  If so, drop the walk and change scene on click.

Write down what they do, not what they say.
